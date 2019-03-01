###
# Page options, layouts, aliases and proxies
###

# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# General configuration
###

config[:images_dir] = 'assets/images'
config[:fonts_dir] = 'assets/fonts'
config[:css_dir] = 'assets/stylesheets'

config[:sass_assets_paths] = ['node_modules']

# ignore js, b/c we're handling with external pipeline
ignore 'assets/javascripts/*'

activate :external_pipeline,
    name: :npm,
    command: build? ? 'yarn build' : 'yarn start',
    source: ".tmp/dist",
    latency: 1

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# run the blog extension
activate :blog do |blog|
    blog.name = "work"
    blog.prefix = "work"
    blog.sources = "{year}/{title}.html"
    blog.permalink = "{category}/{year}/{title}.html"
    blog.layout = "print"
end

config[:blog_summary_separator] = /EXCERPT/

activate :blog do |blog|
    blog.name = "writing"
    blog.prefix = "writing"
    blog.sources = "{year}/{month}-{day}-{title}.html"
    blog.permalink = "{year}/{month}/{title}.html"
    blog.taglink = "tags/{tag}.html"
    blog.summary_length = nil
    blog.summary_separator = config[:blog_summary_separator]
    blog.layout = "blog_post"
    blog.paginate = true
    blog.per_page = 20
end

activate :directory_indexes
page "404.html", :directory_index => false

# explicitly set the markdown engine to Kramdown
config[:markdown_engine] = :kramdown

# Use relative URLs
# activate :relative_assets

# Enable cache buster
# activate :asset_hash

activate :google_analytics do |ga|
    ga.tracking_id = 'UA-51213824-1' # Replace with your property ID.
end

# Reload the browser automatically whenever files change
configure :development do
    activate :livereload
end


###
# Helpers
###

# Methods defined in the helpers block are available in templates
# rubocop:disable Metrics/BlockLength
helpers do

  # check to see if a highlight color is one of the defaults listed in colors.yml
  def highlight(color)
    if data.colors.include? color
      return data.colors[color.to_s]
    else
      return color
    end
  end

  # grab a yml file from an arbitrary location and read it
  # -> used for storing data outside of the 'data' folder
  # -> http://stackoverflow.com/questions/13310488/how-can-i-read-a-yaml-file
  # def getYML(file) {
  #   return YAML.load_file(file)
  # }

  # "Component" decorator for partial function
  # -> just used to point automatically to "components" dir so you don't have to type the full path
  def component(name, opts = {}, &block)
    partial("components/#{name}", opts, &block)
  end

  def class_list(classes)
    list = classes.is_a?(String) ? classes : classes.join(' ')
    return " class='#{list}'" unless classes.empty?
  end

  def props_list(props)
    list = props.is_a?(String) ? props : props.join(' ')
    return "='#{list}'" unless props.empty?
  end

  # figure out the utility padding classes to use
  # arguments:
  # STRING/HASH values (required): size of padding
  # -> Pass in a string to apply the same padding to all sides, e.g. 'wide'
  # -> Pass in a hash to apply padding to each side, e.g. { top: 'narrow' }.
  #    Any sides you leave out will have no padding.
  # rubocop:disable Metrics/MethodLength
  # -> we need all this logic in this method, doesn't make sense to split it up
  def padding_classes(values)
    if values.is_a?(String)
      case values
      when 'none'
        'no-padding'
      when 'medium'
        'padding'
      else
        "padding-#{values}"
      end
    else
      values.collect do |side, width|
        case width
        when 'none'
          "no-padding-#{side}"
        when 'medium'
          "padding-#{side}"
        else
          "padding-#{side}-#{width}"
        end
      end.join(' ')
    end
  end
  # rubocop:enable Metrics/MethodLength

  # figure out the utility border classes to use
  # arguments:
  # ARRAY list (required): a list of the sides that should get borders
  def border_classes(sides)
    if sides.is_a?(String)
      return 'border' if sides == 'all'
      "border-#{sides}"
    else
      sides.collect { |side| "border-#{side}" }.join(' ')
    end
  end

  # build an array of the posts from a given blog
  # STRING
  def get_posts(name)
    posts = []
    blog(name).articles.each do |post|
      posts.push(post)
    end
    return posts
  end

  def find_post_index(post, blog_name = "writing")
    posts = get_posts(blog_name)
    if posts.include?(post)
      return posts.index(post)
    else
      return false
    end
  end

  def next_post(post, blog_name = "writing")
    # find next post in TOC
    if find_post_index(post, blog_name) < (get_posts.length - 1)
      return get_posts[find_post_index(post, blog_name) + 1]
    else
      return false
    end
  end

  def prev_post(post, blog_name = "writing")
    # find previous post in TOC
    if find_post_index(post, blog_name) > 0
      return get_posts[find_post_index(post, blog_name) - 1]
    else
      return false
    end
  end

  def current_page?(url)
    if current_page.url == url then
      return true
    else
      return false
    end
  end
end

set :url_root, 'http://jayperryworks.com'
# activate :search_engine_sitemap

# Use relative links all the time - helps catch url bugs before deployment
set :relative_links, true

# Build-specific configuration
configure :build do

    # Enable cache buster
    # activate :asset_hash

    # autoprefix CSS
    activate :autoprefixer do |config|
      config.browsers = ['last 2 versions', 'Explorer >= 9']
    end

    activate :minify_html
    activate :minify_css

    # "Ignore" JS so webpack has full control.
    # ignore { |path| path =~ /\/(.*)\.js$/ && $1 != 'all' }

    # Minify Javascript on build
    # activate :minify_javascript

    # Compress/optimize images
    # -> svg optimization is handled by svgo
    # activate :imageoptim do |options|
    #     options.image_extensions = %w(.png .jpg .gif .svg)
    # end

    # Or use a different image path
    # set :http_prefix, "/Content/images/"
end

# Copy the server config files in /public after build
# Cheers to Makzan for posting this. https://www.makzan.net/2015/09/configure-files-to-copy-without-middleman-building-process/
after_build do |builder|
  FileUtils.cp_r 'public/.', 'build'
end
