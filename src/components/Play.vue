<template name="play">
  <div id="play">
    <div  class="container">
    <!-- Modal Component -->
    <b-modal id="levelUp" ref="levelUp" title="You've Levelled Up!" ok-only>
      <p class="my-4">
        <h3>Level {{currentLevel.level}}</h3>
        <img :src="currentLevel.img" width="120px" height="120px"/>
        <p class="lead">You've unlocked: {{currentLevel.character}}</p>
      </p>
    </b-modal>

    <div class="main pt-3">

      <div id="game" class="abtext">
        <h4>How many participants?</h4>
        <b-alert show dismissible v-if="userInfo.isAnonymous" variant="danger">
          <router-link to="/login"> Log In</router-link> or <router-link to="/signup"> Sign Up</router-link> now to compete on the leaderboard!
        </b-alert>
        <div v-if="!abstract || status === 'loading'" class="bshelf">
          <bookshelf></bookshelf>
        </div>
        <div v-else class="text-left mt-3" v-html="nlpAbstract">

        </div>

      </div>

      <b-alert :show="dismissCountDown"
         :variant="score.variant"
         class="toast"
         @dismissed="dismissCountdown=0"
         @dismiss-count-down="countDownChanged">
         {{score.message}}
      </b-alert>

    </div>

  </div>
  <b-navbar toggleable="md" type="dark" variant="danger"
    class="navbar-fixed-bottom" id="bottonNav"
    style="">
    <b-navbar-nav is-nav-bar class="ml-auto">
      <b-nav-form>
        <!--<b-button size="md"
         class="my-2 my-sm-0" variant="default" v-b-modal.manualModal> <!-- v-b-tooltip.hover.focus.bottom="'Manual entry'">
          <i class="fa fa-pencil"></i>
        </b-button>-->
        <b-input v-model="N" class="inputManual"></b-input>

      </b-nav-form>
    </b-navbar-nav>

    <b-navbar-nav>
      <b-nav-form>
        <!--<b-form-input size="sm" class="mr-sm-2" type="text" placeholder="Search"/>-->
        <b-button size="md" class="my-2 my-sm-0 ml-2" v-on:click="next">
          <span v-if="status === 'loading'">
            <i class="fa fa-spinner fa-spin"></i>
          </span>
          <span v-else>
            <span v-if="N">
              Submit {{N}}
            </span>
            <span v-else>
              Next
            </span>
          </span>
        </b-button>

      </b-nav-form>
    </b-navbar-nav>



    <!--<b-navbar-nav is-nav-bar class="ml-auto">
      <b-nav-form>
        <b-form-input size="sm" class="mr-sm-2" type="text" placeholder="Search"/>
        <b-button size="sm" class="my-2 my-sm-0">Undo</b-button>
      </b-nav-form>
    </b-navbar-nav>-->
  </b-navbar>
  </div>
</template>

<style>

.btn:not(:disabled):not(.disabled) {
    cursor: pointer;
}

#bottonNav {
  position: fixed !important;
  bottom: 0;
  width: 100%;
  height: 56px;
}

.abtext {
  padding-bottom: 60px;
}

.inputManual {
  width: 75px;
}

  h4.left-align {
    text-align: left;
    padding-top: 30px;
  }

  .nl-Value {
    color: #dc3545;
    cursor: pointer;
    background-color: #ffc1075e;
    padding: 3px;
    border-style: solid;
    border-color: #ffc1075e;
    border-radius: 5px;
    border-width: thin;
    }

  .selectedNumber {
    border-width: thick;
    border-color: #dc3545;
    }

  .bshelf {
    height: 250px;
    position: absolute;
  }

  .text-justify{
    padding-bottom: 40px;
  }

</style>

<script>
  import Vue from 'vue';
  import _ from 'lodash';
  import axios from 'axios';
  import nlp from 'compromise';
  import { VueHammer } from 'vue2-hammer';
  import GridLoader from 'vue-spinner/src/PulseLoader';
  import { db } from '../firebaseConfig';
  import config from '../config';
  import bookshelf from './bookshelf';

  nlp.plugin({
    regex: {
      '[0-9]+': 'Value',
    },
  });

  window.db = db;

  Vue.use(VueHammer);

  Vue.use(require('vue-shortkey'));

  function randomInt(min, max) {
    return Math.floor(Math.random() * ((max - min) + 1)) + min;
  }


  export default {
    name: 'play',
    props: ['userInfo', 'userData', 'levels', 'currentLevel', 'anonID'],
    data() {
      return {
        currentImage: {
        },
        abstract: 'this is the abstract...',
        N: null,
        imageBaseUrl: config.imageBaseUrl,
        startTime: null,
        dismissSecs: 1,
        pointsAward: null,
        dismissCountDown: 0,
        currentAudio: null,
        score: {
          variant: 'warning',
          message: '',
        },
        status: 'loading',
      };
    },
    computed: {
      nlpAbstract() {
        if (this.abstract) {
          const r = nlp(this.abstract);
          return r.out('html');
          /* console.log(r.values().toNumber().out('array'));
          if (r.if('#Value').found) {
            return r.if('#Value').out('html');
          }
          return this.abstracts[this.currentIdx]; */
        }
        return null;
      },
    },
    watch: {
      N() {
        this.$emit('updatedN', this.N);
      },
      status() {
        this.$emit('updatedStatus', this.status);
      },
      currentLevel() {
        console.log('detected change', this.userData.score, this.currentLevel.min);
        if (this.userData.score === this.currentLevel.min && this.currentLevel.min) {
          this.$refs.levelUp.show();
          db.ref(`/users/${this.userInfo.displayName}`).child('level').set(this.currentLevel.level);
        }
      },
      currentImage() {
        axios.get(this.currentImage).then((resp) => {
          console.log('getting data', resp.data);
          this.abstract = resp.data.abstract[0];
        });
      },

      nlpAbstract() {
        const self = this;
        this.$nextTick(() => {
          const numbers = document.getElementsByClassName('nl-Value');
          for (let i = 0; i < numbers.length; i += 1) {
            numbers[i].onclick = function recordNum(e) {
              const classNames = e.target.className;
              const N = parseInt(nlp(e.target.innerHTML).values().toNumber().out(), 10);
              if (classNames.indexOf('selectedNumber') < 0) {
                self.N += N;
                e.target.classList.add('selectedNumber');
              } else {
                e.target.classList.remove('selectedNumber');
                self.N -= N;
              }
            };
          }
        });
      },

    },
    mounted() {
      this.startTime = new Date();
      this.setCurrentAbstract();
    },
    components: { GridLoader, bookshelf },
    directives: {
    },
    methods: {
      next() {
        const totalTime = new Date() - this.startTime;
        console.log('setting N', this.N);
        db.ref('imageCount')
          .child(this.currentCount['.key'])
          .child('N')
          .set(this.N);

        const count = this.currentCount.num_votes || 0;

        db.ref('imageCount')
          .child(this.currentCount['.key'])
          .child('num_votes')
          .set(count + 1);

        let user;
        if (this.userInfo.isAnonymous) {
          user = this.anonID;
        } else {
          user = this.userData['.key'];
        }
        const entry = { vote: this.N,
          user,
          pmid: this.currentCount['.key'],
          time: totalTime,
        };

        db.ref('votes')
          .push(entry);

        // you only get on the leaderboard if you're not anonymous
        if (!this.userInfo.isAnonymous) {
          db.ref('users')
            .child(this.userData['.key'])
            .child('score')
            .set(this.userData.score + 1);
        }

        this.setCurrentAbstract();
      },
      setCurrentAbstract() {
        this.N = 0;
        this.$emit('updatedN', this.N);
        this.status = 'loading';
        this.abstract = '';
        if (!config.N) {
          const fdata = _.filter(this.imageCount,
            val => val.num_votes === this.imageCount[0].num_votes);
          const N = fdata.length;
          this.currentIndex = randomInt(0, N - 1);
          let key = this.currentCount['.key'];
          if (key === this.prevImage) {
            this.currentIndex += 1;
            key = this.currentCount['.key'];
          } else {
            this.prevImage = key;
          }
          console.log('key is', key);
          this.startTime = new Date();
          this.currentImage = `${this.imageBaseUrl}/${key}.${config.imageExt}`;
          console.log(this.currentImage);
          this.status = 'ready';
        } else {
          const idx = randomInt(0, config.N - 1);
          console.log('getting a totally random image', idx);
          db.ref('imageCount').orderByChild('idx').startAt(idx)
            .limitToFirst(1)
            .once('value')
            .then((snap) => {
              console.log('snap is', snap, snap.val(), snap.key, idx);
              const data = snap.val();
              const key = Object.keys(data)[0];
              data[key]['.key'] = key;
              console.log('data snap is', data);
              this.currentImage = `${this.imageBaseUrl}/${key}.${config.imageExt}`;
              this.currentCount = data[key];
              this.startTime = new Date();
              this.status = 'ready';
            });
        }
      },
      countDownChanged(dismissCountDown) {
        this.dismissCountDown = dismissCountDown;
      },
      showAlert() {
        this.dismissCountDown = this.dismissSecs;
      },
    },
  };
</script>
