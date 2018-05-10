<template name="play">
  <div id="play" class="container">
    <!-- Modal Component -->
    <b-modal id="levelUp" ref="levelUp" title="You've Levelled Up!" ok-only>
      <p class="my-4">
        <h3>Level {{currentLevel.level}}</h3>
        <img :src="currentLevel.img" width="120px" height="120px"/>
        <p class="lead">You've unlocked: {{currentLevel.character}}</p>
      </p>
    </b-modal>

    <div class="main">

      <div id="game">
        <h4>Click on the sample size</h4>
        <small>hit Next if the information isn't available</small>

        <div class="text-justify mt-3" v-html="nlpAbstract">

        </div>
        <div class="mt-3 sticky">
          <b-btn variant="primary" @click="next">
            <span v-if="N"> Submit {{N}} </span>
            <span v-else> Next </span>
          </b-btn>
          <b-input v-model="N" class="mt-3 mx-auto text-center" style="width:50px" label="manual"></b-input>
          <small> Manual Input </small>
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
</template>

<style>
  .nl-Value {
    color: blue; /*#dc3545;*/
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


  window.db = db;

  Vue.use(VueHammer);

  Vue.use(require('vue-shortkey'));

  function randomInt(min, max) {
    return Math.floor(Math.random() * ((max - min) + 1)) + min;
  }


  export default {
    name: 'play',
    firebase: {
      // images: db.ref('images'),
      /* imageCount: {
        source: db.ref('imageCount').orderByChild('num_votes').limitToFirst(100),
        readyCallback() {
          console.log('is ready', this.imageCount);
          this.status = 'loading';
          // _.map(this.imageCount, (v) => {
          //  this.preloadImage(v['.key']);
          //  console.log('preloaded', v['.key']);
          // });
          this.setCurrentImage();
        },
      }, */ // DEBUG: uncomment for non-random
    },
    props: ['userInfo', 'userData', 'levels', 'currentLevel'],
    data() {
      return {
        // images: [],
        currentImage: {
          pic: 'data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==', // this is a blank gray base64
        },
        currentCount: {},
        abstract: 'Please be patient, loading...',
        N: 0,
        prevImage: null,
        imageBaseUrl: config.imageBaseUrl,
        currentIndex: null,
        imageCount: [],
        preloaded: null,
        swipe: null,
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
      /* currentCount() {
        return this.imageCount[this.currentIndex];
      }, */ // DEBUG: uncomment for unrandom

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
      currentLevel() {
        console.log('detected change', this.userData.score, this.currentLevel.min);
        if (this.userData.score === this.currentLevel.min && this.currentLevel.min) {
          this.$refs.levelUp.show();
          db.ref(`/users/${this.userInfo.displayName}`).child('level').set(this.currentLevel.level);
        }
      },
      imageCount() {
        /*_.map(this.imageCount, (v) => {
          this.preloadImage(v['.key']);
          // console.log('preloaded', v['.key']);
        });*/
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
    components: { GridLoader },
    directives: {
    },
    methods: {
      next() {
        this.setCurrentAbstract();
      },
      setCurrentAbstract() {
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
      getUntrustedScore(data, vote) {
        const size = data.num_votes;
        const aveVote = data.ave_score;
        const newAve = ((aveVote * size) + vote) / (size + 1);
        console.log('size, preave, newave', size, aveVote, newAve, vote);

        if (size <= 5) {
          // not enough votes to say.
          this.score.message = '+ 1';
          this.score.variant = 'success';
          return { score: 1, ave: newAve, size: size + 1 };
        }

        if (aveVote <= 0.3 || aveVote >= 0.7) {
          // the group feels strongly. Do you agree w/ them?
          if (aveVote <= 0.3 && !vote) {
            this.score.message = '+ 1';
            this.score.variant = 'success';
            return { score: 1, ave: newAve, size: size + 1 };
          } else if (aveVote >= 0.7 && vote) {
            this.score.message = '+ 1';
            this.score.variant = 'success';
            return { score: 1, ave: newAve, size: size + 1 };
          }

          // you disagree w/ the majority. You are penalized
          this.score.message = '+ 0';
          this.score.variant = 'danger';
          return { score: 0, ave: newAve, size: size + 1 };
        }

        this.score.message = '+ 1';
        this.score.variant = 'success';
        return { score: 1, ave: newAve, size: size + 1 };
      },
      swipeLeft() {
        console.log(this.currentCount['.key']);
        this.status = 'loading';
        this.setSwipe('swipe-left');
        const score = this.getUntrustedScore(this.currentCount, 0);
        this.showAlert();
        // set the user score
        db.ref('users').child(this.userInfo.displayName)
          .child('score').set(this.userData.score + score.score);
        // set the image count
        // this.$firebaseRefs.imageCount
        db.ref('imageCount')
            .child(this.currentCount['.key'])
            .set({
              ave_score: score.ave,
              num_votes: score.size,
            });
        // send the actual vote
        this.sendVote(0).then(() => {
          console.log('sent vote');
        });

        this.setCurrentAbstract();
      },
      sendVote(vote) {
        // console.log('this startTime', this.startTime);
        return db.ref('votes').push({
          username: this.userInfo.displayName,
          time: new Date() - this.startTime,
          vote,
          point: this.pointsAward,
          image_id: this.currentCount['.key'],
        });

         /* this.$firebaseRefs.imageCount
          .child(this.currentCount['.key'])
          .child('num_votes')
          .set(this.currentCount.num_votes + 1); */
      },
      computeScore(data, vote) {
        let voteScore = 0;
        let size = 0;

        _.mapValues(data, (v) => {
          voteScore += v.vote;
          size += 1;
          return v.vote;
        });

        const aveVote = voteScore / size;
        const newAve = (voteScore + vote) / (size + 1);

        if (size <= 5) {
          // not enough votes to say.
          this.score.message = '+ 1';
          this.score.variant = 'success';
          return { score: 1, ave: newAve, size: size + 1 };
        }

        if (aveVote <= 0.3 || aveVote >= 0.7) {
          // the group feels strongly. Do you agree w/ them?
          if (aveVote <= 0.3 && !vote) {
            this.score.message = '+ 1';
            this.score.variant = 'success';
            return { score: 1, ave: newAve, size: size + 1 };
          } else if (aveVote >= 0.7 && vote) {
            this.score.message = '+ 1';
            this.score.variant = 'success';
            return { score: 1, ave: newAve, size: size + 1 };
          }

          // you disagree w/ the majority. You are penalized
          this.score.message = '+ 0';
          this.score.variant = 'danger';
          return { score: 0, ave: newAve, size: size + 1 };
        }

        this.score.message = '+ 1';
        this.score.variant = 'success';
        return { score: 1, ave: newAve, size: size + 1 };
      },
      getScore(vote) {
        // get all scores for the images
        // then run computeScore to get the points

        return db.ref('votes')
          .orderByChild('image_id')
          .equalTo(this.currentCount['.key'])
          .once('value')
          .then((snap) => {
            const data = snap.val();
            console.log('snap data is', data);
            const score = this.computeScore(data, vote);
            this.pointsAward = score.score;
            db.ref('users').child(this.userInfo.displayName)
              .child('score').set(this.userData.score + score.score);

            // this.$firebaseRefs.imageCount
            db.ref('imageCount')
                .child(this.currentCount['.key'])
                .set({
                  ave_score: score.ave,
                  num_votes: score.size,
                });
          });
      },
      swipeRight() {
        this.status = 'loading';
        this.setSwipe('swipe-right');
        const score = this.getUntrustedScore(this.currentCount, 1);
        this.showAlert();
        // set the user score
        db.ref('users').child(this.userInfo.displayName)
          .child('score').set(this.userData.score + score.score);
        // set the image count
        db.ref('imageCount')
            .child(this.currentCount['.key'])
            .set({
              ave_score: score.ave,
              num_votes: score.size,
            });

        this.sendVote(1).then(() => {
          console.log('sent vote');
        });

        this.setCurrentImage();
      },
      setSwipe(sw) {
        console.log('setting swipe', sw);
        this.swipe = sw;
      },
      onSwipe(evt) {
        if (evt.direction === 2) {
          this.swipeLeft();
        } else {
          this.swipeRight();
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
