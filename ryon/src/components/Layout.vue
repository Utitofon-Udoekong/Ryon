<script setup>
const TWITTER_HANDLE = "UtitofonUdoeko1";
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
</script>
<template>
  <div className="App">
    <div className="container">
      <div className="header-container">
        <header>
          <div className="left">
            <p className="title">🐱‍👤 Ryon Name Service</p>
            <p className="subtitle">Your immortal API on the blockchain!</p>
          </div>
        </header>
      </div>
      <slot></slot>

      <div className="footer-container">
        <img
          alt="Twitter Logo"
          className="twitter-logo"
          src="@/assets/twitter-logo.png"
        />
        <a
          className="footer-text"
          :href="TWITTER_LINK"
          target="_blank"
          rel="noreferrer"
          >{{ `built with @${TWITTER_HANDLE}` }}</a
        >
      </div>
    </div>
  </div>
</template>
