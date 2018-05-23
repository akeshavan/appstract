# appstract

> a firebase app to annotate abstracts

## Firebase setup

1. Create a firebase account
2. Click on "Web Setup" and copy paste your config into `src/firebaseConfig.js`
3. Go to the Authentication and click "Sign-In method" and enable Email/Password
4. Go to the Database tab and click "Rules" and copy paste the following:

```
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "users": {
      ".read": true,
      ".write": "auth != null",
    },
    "settings": {
      ".read": true,
      ".write": false,
    },
    "imageCount": {
      ".indexOn": ["idx", "num_votes", "ave_score"],
    },
  }
}
```

5. run the app: `npm run dev` and open `localhost:8080`. Create a new account
6. Go to the Database tab in Firebase. Create a key value pairs like this:

```
imageCount: 1
```
7. Click on imageCount. Import a JSON file w/ pointers to your images into here:
```
{
  pmid: {
    N: 0,
    num_votes: 0
  },
  ...
}
```

where each pmid key is the pmid of the abstract you want to annotate. For example see: https://github.com/akeshavan/appstract/blob/master/autism_manifest.json#L1 .

8. Also host your images somewhere else (like S3), it will be cheaper to pull images from there instead of firebase. The images will be found at: `https://yourS3bucket/pmid.json` . The content of the json file should look like: https://d2ndgqavqxbnim.cloudfront.net/autism/21192986.json

9. Edit the `imageBaseUrl` here https://github.com/akeshavan/appstract/blob/master/src/config.js#L3 to point to your abstract json files

10. Start playing to test that it works

11. To deploy. make a firebase directory here:

```
mkdir firebase
cd firebase
firebase init
```

ONLY select the hosting option here. Then choose your project, and say yes to everything else. Then do:

```
cd ..
npm run build
cd firebase
cp -r ../dist/* public/
```

The `npm` step builds all your files into a single html file and a set of js files. Then we move them to the firebase `public` folder and then deploy:

```
firebase deploy
```

These instructions will probably change soon. The app is still being actively developed!

## Build Setup for the Frontend

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build

# build for production and view the bundle analyzer report
npm run build --report
```

For a detailed explanation on how things work, check out the [guide](http://vuejs-templates.github.io/webpack/) and [docs for vue-loader](http://vuejs.github.io/vue-loader).
