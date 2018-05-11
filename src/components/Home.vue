<template>
  <div class="home container">
    <div class="jumbotron landing">
      <h1>{{msg}}</h1>
      <p class="lead buttons mt-3">
        app to annotate abstracts
      </p>
      <p class="buttons mt-3">
        <router-link class="btn btn-primary white" to="/play"> Play Now </router-link>
      </p>
    </div>
    <div id="learnhow">
      <h1>A thing</h1>
      <p>
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
      </p>
    </div>
    <!--<div class="container">
      <div class="row">
        <img class="mx-auto" src="../assets/mainGIF.gif"/>
      </div>
    </div>-->

  </div>


</template>

<script>


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
a {
  color: #42b983;
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

#learnhow {
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
