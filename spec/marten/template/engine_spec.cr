require "./spec_helper"

describe Marten::Template::Engine do
  describe "#get_template" do
    it "returns compiled templates from the underlying loaders" do
      engine = Marten::Template::Engine.new
      engine.loaders << Marten::Template::Loader::FileSystem.new("#{__DIR__}/loader/templates")
      engine.loaders << Marten::Template::Loader::FileSystem.new("#{__DIR__}/loader/other_templates")

      template_1 = engine.get_template("hello_world.html")
      template_1.should be_a Marten::Template::Template
      template_1.render(Marten::Template::Context{"name" => "John Doe"}).should eq "Hello world, John Doe!\n"

      template_2 = engine.get_template("subfolder/hello_world.html")
      template_2.should be_a Marten::Template::Template
      template_2.render(Marten::Template::Context{"name" => "John Doe"}).should eq "Hello world, John Doe!\n"

      template_3 = engine.get_template("foo_bar.html")
      template_3.should be_a Marten::Template::Template
      template_3.render(Marten::Template::Context.new).should eq "Foo Bar\n"
    end

    it "raises a TemplateNotFound error if the template cannot be found" do
      engine = Marten::Template::Engine.new
      engine.loaders << Marten::Template::Loader::FileSystem.new("#{__DIR__}/loader/templates")
      engine.loaders << Marten::Template::Loader::FileSystem.new("#{__DIR__}/loader/other_templates")

      expect_raises(
        Marten::Template::Errors::TemplateNotFound,
        "Template unknown.html could not be found"
      ) do
        engine.get_template("unknown.html")
      end
    end
  end
end
