---
layout: default
title: KyleSJohnston.com
description: Kyle S. Johnston's Personal Webpage
---

**Note:** Page construction in progress...

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