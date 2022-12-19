---
layout: default
title: KyleSJohnston.github.io
description: Kyle S. Johnston's Personal Webpage
---

## About Me

I work in quantitative finance at a hedge fund. My current language is Python, but I'm experimenting with Julia. (I'm convinced the two-language problem is worth solving most of the time.)

I enjoy applying data and analytics to the sports world. I'm a fan of all the Boston teams&mdash;Patriots, Bruins, Celtics and RedSox

## Connect

- <a href="https://github.com/KyleSJohnston">GitHub</a>
- <a href="https://www.linkedin.com/in/KyleSJohnston/">LinkedIn</a>
- <a href="https://fosstodon.org/@ksj" rel="me">Mastodon</a>
- <a href="https://twitter.com/KyleSJohnston">Twitter</a>

{% comment %}
{% for post in site.posts %}
  <article>
    <h2>
      <a href="{{ post.url }}">
        {{ post.title }}
      </a>
    </h2>
    <time datetime="{{ post.date | date: "%Y-%m-%d" }}">{{ post.date | date_to_long_string }}</time>
    {{ post.content }}
  </article>
{% endfor %}
{% endcomment %}
