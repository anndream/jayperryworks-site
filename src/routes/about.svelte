<script context="module">
  export async function preload() {
    const response = await this.fetch('about.json')
    const content = await response.json()

    if (response.status !== 200) {
      this.error(response.status, content.message)
      return
    }

    return { content }
  }
</script>

<script>
  import Cover from '@/components/Cover.svelte'
  import MainNav from '@/components/MainNav.svelte'
  import PostBody from '@/components/PostBody.svelte'
  import ResponsiveImage from '@/components/ResponsiveImage.svelte'
  import Wrapper from '@/components/Wrapper.svelte'

  export let content
</script>

<MainNav segment="about" />
<main>
  <article class="
    padding-x-outside
    padding-y-xwide
  ">
    <header>
      <Wrapper
        width="wide"
        class="t-align-center@small padding-bottom-wide"
      >
        <h1 class="t-align-center@small">{content.title}</h1>
        {#if content.cover}
          <Cover
            class="padding-top-wide"
            sources={content.cover.sources}
            alt={content.cover.alt}
            caption={content.cover.caption}
            credit={content.cover.credit}
          />
        {/if}
      </Wrapper>
    </header>

    <PostBody sections={content.body} />
  </article>
</main>
