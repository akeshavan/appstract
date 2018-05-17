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
        <h4 class="text-left">How many participants?</h4>
        <b-alert show dismissible v-if="userInfo.isAnonymous" variant="danger">
          <router-link to="/login"> Log In</router-link> or <router-link to="/signup"> Sign Up</router-link> now to compete on the leaderboard!
        </b-alert>
        <div v-if="!abstract || status === 'loading'" class="bshelf">
          <bookshelf></bookshelf>
        </div>
        <div v-else class="text-left mt-3" v-html="nlpAbstract" v-hammer:swipe.horizontal="onSwipe">

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

  <b-modal id="manualModal" title="Flag As" hide-footer ref="manual">
    <b-form @submit="preventSubmit">
      <b-button class="mt-3 w-100" @click="flag('review')">Review Article</b-button>
      <b-button class="mt-3 w-100" @click="flag('N/A')">Not Available/Skip</b-button>
      <b-button class="mt-3 w-100" @click="flag('n1')">Case Study (n=1)</b-button>
      <b-button class="mt-3 w-100" @click="flag('not_relevant')">Not Relevant</b-button>
    </b-form>
  </b-modal>

  <b-navbar toggleable="md" type="dark" variant="danger"
    class="navbar-fixed-bottom" id="bottonNav"
    style="">

    <b-navbar-nav is-nav-bar class="">
      <b-nav-form>
        <b-button size="md" class="my-2 my-sm-0 ml-2 ml-auto" v-b-modal.manualModal>
          <i class="fa fa-flag"></i>
        </b-button>
      </b-nav-form>
    </b-navbar-nav>

    <b-navbar-nav is-nav-bar class="mx-auto">
      <b-nav-form @submit="preventSubmit">
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
              Skip
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

    .nl-Disease {
      color: #007BF5;
    }

    .nl-StudyType {
      color: #0c5460;
      background: #e9ecef6e;
      padding: 1px;
      border-radius: 5px;
    }

    .nl-Animal {
        color: #0c5460;
        background: #e9ecef;
        padding: 1px;
        border-radius: 5px;
    }

    .nl-Method {
        color: #0c5460;
        background: #e9ecef;
        padding: 1px;
        border-radius: 5px;
    }



    .nl-Instrumentation {
        color: #1b1e21;
        /* background-color: #80bdff6e; */
        /* padding: 3px; */
        border-bottom-style: solid;
        border-bottom-width: initial;
        border-right-style: none;
        border-left-style: none;
        border-top-style: none;
        /* border-style: solid; */
        border-color: #dc35458f;
        border-radius: 5px;
        /* border-width: thin; */
    }

  .selectedNumber {
    border-width: thick;
    border-color: #dc3545;
    }

  .bshelf {
    height: 250px;
    position: absolute;
  }

  @media (min-width: 768px) {
    .bshelf {
      left: 0;
      right: 0;
    }
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
    firebase: {
      imageCount: {
        source: db.ref('imageCount').orderByChild('num_votes').limitToFirst(30),
        readyCallback() {
          console.log('is ready', this.imageCount);
          this.status = 'loading';
          /*_.map(this.imageCount, (v) => {
            this.preloadImage(v['.key']);
            console.log('preloaded', v['.key']);
          });*/
          this.setCurrentAbstract();
        },
      },
    },
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
        currentCount: {},
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
          const strippedAbstract = this.abstract
            .replace(/([a-zA-Z]+[\,\.\)\}\]\!\?]+)(\d)/g, '$1 $2')
            .replace(/(\d+[\,\.\)\}\]\!\?]+)([a-zA-Z]+)/g, '$1 $2')
            .replace(/([a-zA-Z]+)\s?\=\s?(\d)/g, '$1 = $2');
          // console.log(nlp(strippedAbstract).match('autism').out('html'));
          const myWords={
            'autism':'Disease',
            'autism spectrum':'Disease',
            'autistic':'Disease',
            'asperger':'Disease',
            'ASD':'Disease',
            'ASC':'Disease',
            'review':'StudyType',
            'reviews':'StudyType',
            'meta analysis':'StudyType',
            'meta-analysis':'StudyType',
            'mice':'Animal',
            'fmri': 'MRISequence',
            'voxel-based morphometry': 'Method',
            'voxel based morphometry': 'Method',
            'VBM': 'Method',
            'Transcranial Magnetic Stimulation': 'Instrumentation',
            'TMS': 'Instrumentation',
            'EEG': 'Instrumentation',
            'functional magnetic resonance': 'Instrumentation',
            'magnetic resonance': 'Instrumentation',
            'structural resonance': 'Instrumentation',
            'diffusion tensor': 'Instrumentation',
            'diffusion': 'Instrumentation',
            'neuroimaging': 'Instrumentation',
            'MRI': 'Instrumentation',
            'DT- MRI': 'Instrumentation',
            'DT-MRI': 'Instrumentation',
            'T1': 'Instrumentation',
            'T2': 'Instrumentation',
            'FLAIR': 'Instrumentation',
            'PD': 'Instrumentation',
            'T1-weighted': 'Instrumentation',
            'T(1)-weighted': 'Instrumentation',
            'T1 weighted': 'Instrumentation',
          };
          return nlp(strippedAbstract, myWords).out('html');
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
          // console.log('getting data', resp.data);
          this.abstract = resp.data.abstract;
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
      flag(inp) {
        switch (inp) {
          case 'n1':
            this.N = 1;
            break;
          case 'N/A':
            this.N = 0;
            break;
          case 'review':
            this.N = -1;
            break;
          case 'not_relevant':
            this.N = -2;
            break;
          default:
            break;
        }
        this.$refs.manual.hide();
        this.next();
      },
      preventSubmit(e) {
        e.preventDefault();
        this.next();
      },
      onSwipe(evt) {
        if (evt.direction === 2) {
          this.$refs.manual.show();
        } else {
          this.next();
        }
      },
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
        if (!config.N || !this.userInfo.isAnonymous) {
          console.log('prioritizing unseen images')
          const fdata = _.filter(this.imageCount,
            val => val.num_votes === this.imageCount[0].num_votes);
          console.log('fdata', fdata)
          const N = fdata.length;
          this.currentIndex = randomInt(0, N - 1);
          this.currentCount = this.imageCount[this.currentIndex];
          let key = this.currentCount['.key'];
          if (key === this.prevImage) {
            this.currentIndex += 1;
            this.currentCount = this.imageCount[this.currentIndex];
            key = this.currentCount['.key'];
          } else {
            this.prevImage = key;
          }
          this.startTime = new Date();
          this.currentImage = `${this.imageBaseUrl}/${key}.${config.imageExt}`;
          this.status = 'ready';
        } else {
          console.log('Random Sampling');
          const idx = randomInt(0, config.N - 1);
          // console.log('getting a totally random image', idx);
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
