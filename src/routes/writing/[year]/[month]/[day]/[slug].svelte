<script context="module">
  export async function preload({ params, query }) {
    const { year, month, day, slug } = params
    // the `slug` parameter is available because
    // this file is called [slug].svelte
    const response = await this.fetch(`writing/${year}/${month}/${day}/${slug}.json`);
    const data = await response.json();

    if (response.status !== 200) {
      this.error(response.status, data.message)
      return
    }

    return {
      post: data,
      date: {
        year,
        month,
        day
      }
    }
  }
</script>

<script>
  import { format } from 'date-fns'
  import Card from '@/components/Card.svelte'
  import Cover from '@/components/Cover.svelte'
  import Figure from '@/components/Figure.svelte'
  import PageTitle from '@/components/PageTitle.svelte'
  import PostBody from '@/components/PostBody.svelte'
  import ResponsiveImage from '@/components/ResponsiveImage.svelte'
  import Wrapper from '@/components/Wrapper.svelte'

  export let post;
  export let date;

  function formatDate(formatString) {
    return format(new Date(date.year, date.month, date.day), formatString)
  }
</script>

<PageTitle title="{post.title}" />

<article class="
  padding-x-outside
  padding-y-xwide
">
  <header>
    <Wrapper
      width="wide"
      class="t-align-center@small"
    >
      <h1>{post.title}</h1>
      {#if post.subtitle}
        <p class="
          c-fg-tertiary
          padding-top-xxnarrow
          t-font-accent
          t-heading
          t-scale-beta
        ">{post.subtitle}</p>
      {/if}

      {#if post.cover}
        <Cover
          class="padding-top-wide"
          sources={post.cover.sources}
          alt={post.cover.alt}
          caption={post.cover.caption}
          credit={post.cover.credit}
        />
      {/if}
    </Wrapper>
    <Wrapper class="
      border-bottom
      margin-bottom
      padding-bottom-xnarrow
      padding-top-xwide
    ">
      <time
        class="
          c-fg-tertiary
          t-font-accent
          t-scale-zeta
          t-weight-bold
        "
        datetime={formatDate('yyyy-M-dd')}
      >
        {formatDate('MMMM d, yyyy')}
      </time>
    </Wrapper>
  </header>

  <PostBody sections={post.body} />

  <footer>
    <Wrapper class="
      border-top
      padding-top-wide
      margin-top-wide
    ">
      <Card
        el="aside"
        figureSize="small"
      >
        <img
          slot="figure"
          src="images/portrait.jpg"
          alt="Portrait"
        >
        <div slot="content">
          <p>Jay Perry is a designer, illustrator, and writer living near Baltimore. He likes books, old rusty cars, and forests.</p>
          <a
            href="/about"
            class="
              display-block
              padding-top-narrow
              t-case-upper
              t-font-accent
              t-link-undecorated
              t-scale-zeta
              t-weight-bold
            "
          >More about Jay &rsaquo;</a>
        </div>
      </Card>
    </Wrapper>
  </footer>
</article>
