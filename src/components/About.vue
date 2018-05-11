<template>
  <div id="about" class="mt-3">
    <h1> About appstract. </h1>

    <b-container>
      <p> <b>Why are we doing this?</b>
Free  text descriptions of studies are messy and it is really hard to separate the  content into valuable nuggets of metadata. To do this on our own would take  hundreds of years. With your help we can get the answers in only a few days!
Apparently,  the number of people participating in research studies is increasing - but is  this actually true? We don't know, because we don’t have the data. By tracking  the number of participants used in studies over time we can answer this  question and get a greater understanding of how research is evolving over time.
Once  we have proved that we can get this data with participant size we can start to  fry bigger fish - like statistics. By understanding sample size and study power  together, we can truly understand the quality of a study.

<b>How you're helping.</b>
It's  not about any number, it's about the number of people who took part in a study.  To figure out that you need to takin into account the context around the  number. Computers really struggle to do this sort of thing, but humans are  great at it. That's why we need you!

By  breaking down this information you are:
<ul>
  <li>Helping researchers - by accelerating their research your helping science advance faster.</li>
  <li>Helping computers - with enough human input we can create a 'training' dataset that we can use to help teach computers how to do this work.</li>
</ul> </p>

      <p>
        You can unlock the following animals based on the number of points you have:
      </p>

      <b-container fluid class="p-4">
        <b-row>
          <b-col v-for="lev in levels" v-if="lev.img">
            <div >
              <b-img fluid class="pokemon" :src="lev.img_grey" alt="Thumbnail"/>
              <br>
              Level {{lev.level}}
              <br>
              <span>{{lev.min}} points</span>
            </div>
          </b-col>
        </b-row>
      </b-container>

    </b-container>
    <div class="bottom text-center">
      <small> * icons on this site were
        <a href='https://www.freepik.com/free-vector/cute-woodland-animals_1585897.htm'>Designed by Freepik</a>
      </small>
    </div>
  </div>

</template>

<style>

.pokemon{
  min-width: 25px;
  min-height: 25px;
  width: 100px;
  height: 100px;
}


#about {
  min-height: 100vh;
}

</style>

<script>
export default {
  name: 'about',
  data() {
    return {
      count: 1,
    };
  },
  props: ['levels'],
};
</script>
