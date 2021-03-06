require "spec_helper"

RSpec.describe Jekyll::AssetsPlugin::Tag do
  let(:context) { { :registers => { :site => @site } } }

  def render(content)
    ::Liquid::Template.parse(content).render({}, context)
  end

  def not_found_error(file)
    "Liquid error: Couldn't find file '#{file}'"
  end

  context "{% image <file> %}" do
    def tag_re(name)
      file = "/assets/#{name}-[a-f0-9]{32}\.png"
      Regexp.new "^#{Jekyll::AssetsPlugin::Renderer::IMAGE % file}$"
    end

    context "when <file> exists" do
      subject { render("{% image noise.png %}") }
      it { is_expected.to match tag_re("noise") }
    end

    context "when <file> does not exists" do
      subject { render("{% image not-found.png %}") }
      it { is_expected.to match not_found_error "not-found.png" }
    end
  end

  context "{% stylesheet <file> %}" do
    def tag_re(name)
      file = "/assets/#{name}-[a-f0-9]{32}\.css"
      Regexp.new "^#{Jekyll::AssetsPlugin::Renderer::STYLESHEET % file}$"
    end

    context "when <file> exists" do
      subject { render("{% stylesheet app.css %}") }
      it { is_expected.to match tag_re("app") }
    end

    context "when <file> extension is omited" do
      subject { render("{% stylesheet app %}") }
      it { is_expected.to match tag_re("app") }
    end

    context "when <file> does not exists" do
      subject { render("{% stylesheet not-found.css %}") }
      it { is_expected.to match not_found_error "not-found.css" }
    end
  end

  context "{% javascript <file> %}" do
    def tag_re(name)
      file = "/assets/#{name}-[a-f0-9]{32}\.js"
      Regexp.new "^#{Jekyll::AssetsPlugin::Renderer::JAVASCRIPT % file}$"
    end

    context "when <file> exists" do
      subject { render("{% javascript app.js %}") }
      it { is_expected.to match tag_re("app") }
    end

    context "when <file> extension omited" do
      subject { render("{% javascript app %}") }
      it { is_expected.to match tag_re("app") }
    end

    context "when <file> does not exists" do
      subject { render("{% javascript not-found.js %}") }
      it { is_expected.to match not_found_error "not-found.js" }
    end
  end

  context "{% asset_path <file.ext> %}" do
    context "when <file> exists" do
      subject { render("{% asset_path app.css %}") }
      it { is_expected.to match(%r{^/assets/app-[a-f0-9]{32}\.css$}) }
    end

    context "when <file> does not exists" do
      subject { render("{% asset_path not-found.js %}") }
      it { is_expected.to match not_found_error "not-found.js" }
    end

    context "with baseurl given as /foobar/" do
      before do
        context[:registers][:site].assets_config.baseurl = "/foobar/"
      end

      subject { render("{% asset_path app.css %}") }
      it { is_expected.to match(%r{^/foobar/app-[a-f0-9]{32}\.css$}) }
    end
  end

  context "{% asset <file.ext> %}" do
    context "when <file> exists" do
      subject { render("{% asset app.css %}") }
      it { is_expected.to match(/body \{ background-image: url\(.+?\) \}/) }
    end

    context "when <file> does not exists" do
      subject { render("{% asset_path not-found.js %}") }
      it { is_expected.to match not_found_error "not-found.js" }
    end
  end
end
