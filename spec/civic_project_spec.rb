require './spec_helper.rb'

describe CivicProject do

  EXAMPLE_ATTRS = {
    :KEY => "project_key",
    :NAME => "Project Name",
    :DESCRIPTION => "This is a description of the project.",
    :TYPE => "web application",
    :STATUS => "in development",
  }.freeze

  EXAMPLE_ATTRS_LIST = [
    ["key", "project_key"],
    ["name", "Project Name"],
    ["description", "This is a description of the project."],
    ["type", "web application"],
    ["status", "in development"],
  ].freeze

  describe ".new" do
    it "creates an instance" do
      a = CivicProject.new(EXAMPLE_ATTRS)
      a.should be_instance_of CivicProject
    end
    it "fails when required arguments are missing" do
      expect do
        CivicProject.new(EXAMPLE_ATTRS.merge("key" => nil))
      end.to raise_error(CivicProject::ValidationError)
    end
    it "fails when bad values are specified" do
      expect do
        CivicProject.new(EXAMPLE_ATTRS.merge("status" => "cupcakes"))
      end.to raise_error(CivicProject::ValidationError)
    end
  end

  describe ".load_yml" do
    before(:each) do
      @a = CivicProject.load_yml("#{EXAMPLES_DIR}/austin-restaurant-scores.yml")
    end
    it "creates an instance from a YML file" do
      @a.should be_instance_of CivicProject
    end
    it "loads the project description from YML" do
      @a.to_h.should == {
        :KEY => "austin-restaurant-scores",
        :NAME => "Austin Restaurant Scores",
        :DESCRIPTION => "Application to query Austin/Travis County Health Department restaurant inspection scores.",
        :ACCESS_AT => "http://open-austin.github.io/atx-restaurant-scores/public/index.html",
        :PROJECT_AT => "https://github.com/open-austin/atx-restaurant-scores",
        :TYPE => "web application",
        :STATUS => "beta",
        :CATEGORIES => [ "food safety" ],
        :CONTACT => "hack@open-austin.org",
      }
    end
  end

  describe ".load_dir" do
    it "returns a list of project descriptions" do
      @a = CivicProject.load_dir(EXAMPLES_DIR)
      @a.should be_instance_of Array
      @a.length.should be 2
      @a[0].should be_instance_of CivicProject
    end
    it "fails if no project specs found" do
      expect do
        CivicProject.load_dir("/no/yml/files/here")
      end.to raise_error(RuntimeError)
    end
  end

  describe ".canonicalize_key" do
    it "produces a canonical field key" do
      v = CivicProject.canonicalize_key("description")
      v.should be :DESCRIPTION
    end
    it "returns a canonical field key unchanged" do
      v1 = :DESCRIPTION
      v2 = CivicProject.canonicalize_key(v1)
      v2.should be v1
    end
    it "rejects an unknown field" do
      expect do
        CivicProject.canonicalize_key(:CUPCAKES)
      end.to raise_error(CivicProject::ValidationError)
    end
  end

  describe ".validate_value!" do

    describe ":REQUIRED attribute" do
      it "accepts a non-empty value when :REQUIRED is true" do
        expect do
          CivicProject.validate_value!("cupcakes", {:REQUIRED => true})
        end #.to not_raise_error
      end
      it "rejects an empty string when :REQUIRED is true" do
        expect do
          CivicProject.validate_value!("", {:REQUIRED => true})
        end.to raise_error(CivicProject::ValidationError)
      end
      it "accepts an empty string when :REQUIRED is false" do
        expect do
          CivicProject.validate_value!("", {})
        end #.to not_raise_error
      end
    end # describe ":REQUIRED attribute"

    describe ":TYPE attribute" do
      it "accepts a scalar value when :TYPE is :SCALAR" do
        expect do
          CivicProject.validate_value!("cupcakes", {:TYPE => :SCALAR})
        end #.to not_raise_error
      end
      it "rejects a list value when :TYPE is :SCALAR" do
        expect do
          CivicProject.validate_value!(["cupcakes"], {:TYPE => :SCALAR})
        end.to raise_error(CivicProject::ValidationError)
      end
      it "accepts a list value when :TYPE is :LIST" do
        expect do
          CivicProject.validate_value!(["cupcakes"], {:TYPE => :LIST})
        end #.to not_raise_error
      end
      it "rejects a scalar value when :TYPE is :LIST" do
        expect do
          CivicProject.validate_value!("cupcakes", {:TYPE => :LIST})
        end.to raise_error(CivicProject::ValidationError)
      end
    end # describe ":TYPE attribute"

    describe ":VALUES attribute" do
      it "accepts a scalar value that is in the :VALUES list" do
        expect do
          CivicProject.validate_value!("red", {:VALUES => ["red", "green", "blue"]})
        end #.to not_raise_error
      end
      it "rejects a scalar value that is not in the :VALUES list" do
        expect do
          CivicProject.validate_value!("cupcakes", {:VALUES => ["red", "green", "blue"]})
        end.to raise_error(CivicProject::ValidationError)
      end
      it "accepts an empty scalar value" do
        expect do
          CivicProject.validate_value!("", {:VALUES => ["red", "green", "blue"]})
        end #.to not_raise_error
      end
      it "accepts a list when all values are is in the :VALUES list" do
        expect do
          CivicProject.validate_value!(["blue", "green", "red"], {:VALUES => ["red", "green", "blue"]})
        end #.to not_raise_error
      end
      it "rejects a list when any value is not in the :VALUES list" do
        expect do
          CivicProject.validate_value!(["blue", "green", "cupcakes", "red"], {:VALUES => ["red", "green", "blue"]})
        end.to raise_error(CivicProject::ValidationError)
      end
      it "accepts an empty list value" do
        expect do
          CivicProject.validate_value!([], {:VALUES => ["red", "green", "blue"]})
        end #.to not_raise_error
      end
    end # describe ":VALUES attribute"

    describe ":MATCHES attribute" do
      it "accepts a matching value" do
        expect do
          CivicProject.validate_value!("http://example.com", {:MATCHES => %r{^https?://}})
        end #.to not_raise_error
      end
      it "rejects a non-matching value" do
        expect do
          CivicProject.validate_value!("cupcakes", {:MATCHES => %r{^https?://}})
        end.to raise_error(CivicProject::ValidationError)
      end
    end # describe ":MATCHES attribute"

  end # describe ".validate_value!" 

  describe "#[]" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "returns initialized value" do
      @a[:KEY].should == "project_key"
    end
    it "properly canonicalizes the field name" do
      @a["Key"].should == "project_key"
    end
    it "returns nil for uninitialized value" do
      @a[:ACCESS_AT].should be nil
    end
  end

  describe "#[]=" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "should set a value" do
      @a[:KEY] = "changed"
      @a[:KEY].should == "changed"
    end
    it "properly canonicalizes the field name" do
      @a["Key"] = "changed"
      @a[:KEY].should == "changed"
    end
    it "performs field validation" do
      expect do
        @a[:KEY] = nil
      end.to raise_error(CivicProject::ValidationError)
    end
  end

  describe "#is_type?" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "accepts same type" do
      @a.is_type?("web application").should be true
    end
    it "is case independent" do
      @a.is_type?("Web Application").should be true
    end
    it "rejects different type" do
      @a.is_type?("desktop application").should be false
    end
  end

  describe "#is_status?" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "accepts same status" do
      @a.is_status?("in development").should be true
    end
    it "is case independent" do
      @a.is_status?("In Development").should be true
    end
    it "rejects different status" do
      @a.is_status?("beta").should be false
    end
  end

  describe "#type_index" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "returns position into VALID_TYPES of type" do
      idx = @a.type_index
      @a[:TYPE].should == CivicProject::VALID_TYPES[idx]
    end
  end

  describe "#status_index" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "returns position into VALID_STATUSES of status" do
      idx = @a.status_index
      @a[:STATUS].should == CivicProject::VALID_STATUSES[idx]
    end
  end

  describe "#to_h" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "returns values as a hash" do
      @a.to_h.should == EXAMPLE_ATTRS
    end
  end

  describe "#to_list" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS)
    end
    it "returns values as a hash" do
      @a.to_list.should == EXAMPLE_ATTRS_LIST
    end
  end

  describe "#<=>" do
    before(:each) do
      @a = CivicProject.new(EXAMPLE_ATTRS.merge(:NAME => "aaaa"))
      @b = CivicProject.new(EXAMPLE_ATTRS.merge(:NAME => "bbbb"))
    end
    it "returns 0 when node is compared to itself" do
      (@a <=> @a).should be 0
    end
    it "returns -1 when smaller node is compared to larger node" do
      (@a <=> @b).should be -1
    end
    it "returns 1 when larger node is compared to smaller node" do
      (@b <=> @a).should be 1
    end
  end

end # describe CivicProject 

