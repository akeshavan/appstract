<template>
  <div class="home container">
    <div class="jumbotron landing">
      <h1>{{msg}}</h1>
      <p class="lead buttons mt-3">
        Be part of the movement to make science better
      </p>
      <p class="buttons mt-3">
        <router-link class="btn btn-primary white" to="/play"> Play Now </router-link>
        <b-button v-scroll-to="'#learnhow0'">Learn How</b-button>
      </p>
    </div>
    <div id="learnhow0" class="instruction">
      <h1 >Tap the number</h1>
      <p class="w-100 text-center">
        <img class="phone mx-auto d-block" src="https://media.giphy.com/media/fxR1CmdpkHMVVarKlp/giphy.gif"/>
      </p>
      <p class="text-center">
        Tap the number (or multiple numbers) that represent the number of samples used in the study.
      </p>
      <p class="mt-3 w-100 text-center">
        <b-button v-scroll-to="'#learnhow1'" class="mx-auto">Next</b-button>
      </p>
    </div>

    <div id="learnhow1" class="instruction w-100">
      <h1>Or type it in</h1>
      <p class="w-100 text-center">
        <img class="phone mx-auto d-block" src="https://media.giphy.com/media/fx2c9xgGUn3b7jtLJP/giphy.gif"/>
      </p>
      <p class="text-center">
        If the number isn't highlighted or if it's a case study, add the number in the 'manual' box.
        If there is no number mentioned, click 'next'.
      </p>
      <p class="mt-3 w-100 text-center">
        <b-button v-scroll-to="'#learnhow2'" class="mx-auto">Next</b-button>
      </p>
    </div>


    <div id="learnhow2" class="instruction">
      <h1>Compete</h1>
      <p class="w-100 text-center">
        <img class="fans" src="../assets/undraw_fans.svg"/>
      </p>

      <p class="text-center">
        Hit submit to get a point.
        <router-link to="/login"> Log in</router-link> or <router-link to="/signup"> sign up</router-link> now to compete on the
        <router-link to="/leaderboard">leaderboard!</router-link>
      </p>
      <p class="mt-3 w-100 text-center">
        <router-link class="btn btn-primary white mx-auto" to="/play"> Play Now </router-link>
      </p>
    </div>


    <!--<div class="container">
      <div class="row">
        <img class="mx-auto" src="../assets/mainGIF.gif"/>
      </div>
    </div>-->

    <div class="bottom text-center">
      <small> * icons on this site were
        <a href='https://www.freepik.com/free-vector/cute-woodland-animals_1585897.htm'>Designed by Freepik</a>
      </small>
    </div>

  </div>


</template>

<script>

import Vue from 'vue';

const VueScrollTo = require('vue-scrollto');
window.vst = VueScrollTo;

Vue.use(VueScrollTo, {
  offset: -100,
});


export default {
  name: 'Home',
  data() {
    return {
      msg: 'appstract.',
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.phone {
  max-height: 300px;
  border-style: solid;
  border-radius: 5px;
  border-width: 10px;
  border-color: #535361;
}

.fans {
  max-height: 300px;
}

.home {
  min-height: 100vh;
}

h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}

.home {
  text-align: left;
}

.home h1 {
  text-align: center;
}

.buttons {
  text-align: center;
}

.landing {
  background-color: white;
  background-image: url('../assets/landingIcon.svg');
  background-repeat: no-repeat;
  background-position: center;
  height: 80vh;
}

.instruction {
  height: 80vh;
}

.landing h1 {
  background-color: black;
  color: white;
  max-width: 250px;
  margin: auto;
}

.landing .lead {
  background-color: black;
  color: white;
  max-width: 250px;
  margin: auto;
}

.white {
  color: white;
}

</style>
