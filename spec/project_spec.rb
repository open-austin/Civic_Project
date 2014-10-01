require './spec_helper.rb'

module AFPD
  describe Project do

    describe ".new" do
      it "creates an instance" do
        a = AFPD::Project.new("key" => "key", "name" => "name", "description" => "description")
        a.should be_instance_of AFPD::Project
      end
      it "fails when required arguments are missing" do
        expect do
          AFPD::Project.new("key" => "key", "name" => "name")
        end.to raise_error(ValidationError)
      end
      it "fails when bad values are specified" do
        expect do
          AFPD::Project.new("key" => "key", "name" => "name", "description" => "description", "status" => "cupcakes")
        end.to raise_error(ValidationError)
      end
    end

    describe ".load_yml" do
      before(:each) do
        @a = AFPD::Project.load_yml("#{EXAMPLES_DIR}/austin-restaurant-scores.yml")
      end
      it "creates an instance from a YML file" do
        @a.should be_instance_of AFPD::Project
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
          :CONTACTS => [ "hack@open-austin.org" ],
        }
      end
    end

    describe ".load_dir" do
      it "returns a list of project descriptions" do
        @a = AFPD::Project.load_dir(EXAMPLES_DIR)
        @a.should be_instance_of Array
        @a.length.should be 2
        @a[0].should be_instance_of AFPD::Project
      end
      it "fails if no project specs found" do
        expect do
          AFPD::Project.load_dir("/no/yml/files/here")
        end.to raise_error(RuntimeError)
      end
    end

    describe ".canonicalize_key" do
      it "produces a canonical field key" do
        v = AFPD::Project.canonicalize_key("description")
        v.should be :DESCRIPTION
      end
      it "returns a canonical field key unchanged" do
        v1 = :DESCRIPTION
        v2 = AFPD::Project.canonicalize_key(v1)
        v2.should be v1
      end
      it "rejects an unknown field" do
        expect do
          AFPD::Project.canonicalize_key(:CUPCAKES)
        end.to raise_error(ValidationError)
      end
    end

    describe ".validate_value!" do

      describe ":REQUIRED attribute" do
        it "accepts a non-empty value when :REQUIRED is true" do
          expect do
            AFPD::Project.validate_value!("cupcakes", {:REQUIRED => true})
          end #.to not_raise_error
        end
        it "rejects an empty string when :REQUIRED is true" do
          expect do
            AFPD::Project.validate_value!("", {:REQUIRED => true})
          end.to raise_error(ValidationError)
        end
        it "accepts an empty string when :REQUIRED is false" do
          expect do
            AFPD::Project.validate_value!("", {})
          end #.to not_raise_error
        end
      end # describe ":REQUIRED attribute"

      describe ":TYPE attribute" do
        it "accepts a scalar value when :TYPE is :SCALAR" do
          expect do
            AFPD::Project.validate_value!("cupcakes", {:TYPE => :SCALAR})
          end #.to not_raise_error
        end
        it "rejects a list value when :TYPE is :SCALAR" do
          expect do
            AFPD::Project.validate_value!(["cupcakes"], {:TYPE => :SCALAR})
          end.to raise_error(ValidationError)
        end
        it "accepts a list value when :TYPE is :LIST" do
          expect do
            AFPD::Project.validate_value!(["cupcakes"], {:TYPE => :LIST})
          end #.to not_raise_error
        end
        it "rejects a scalar value when :TYPE is :LIST" do
          expect do
            AFPD::Project.validate_value!("cupcakes", {:TYPE => :LIST})
          end.to raise_error(ValidationError)
        end
      end # describe ":TYPE attribute"

      describe ":VALUES attribute" do
        it "accepts a scalar value that is in the :VALUES list" do
          expect do
            AFPD::Project.validate_value!("red", {:VALUES => ["red", "green", "blue"]})
          end #.to not_raise_error
        end
        it "rejects a scalar value that is not in the :VALUES list" do
          expect do
            AFPD::Project.validate_value!("cupcakes", {:VALUES => ["red", "green", "blue"]})
          end.to raise_error(ValidationError)
        end
        it "accepts an empty scalar value" do
          expect do
            AFPD::Project.validate_value!("", {:VALUES => ["red", "green", "blue"]})
          end #.to not_raise_error
        end
        it "accepts a list when all values are is in the :VALUES list" do
          expect do
            AFPD::Project.validate_value!(["blue", "green", "red"], {:VALUES => ["red", "green", "blue"]})
          end #.to not_raise_error
        end
        it "rejects a list when any value is not in the :VALUES list" do
          expect do
            AFPD::Project.validate_value!(["blue", "green", "cupcakes", "red"], {:VALUES => ["red", "green", "blue"]})
          end.to raise_error(ValidationError)
        end
        it "accepts an empty list value" do
          expect do
            AFPD::Project.validate_value!([], {:VALUES => ["red", "green", "blue"]})
          end #.to not_raise_error
        end
      end # describe ":VALUES attribute"

      describe ":MATCHES attribute" do
        it "accepts a matching value" do
          expect do
            AFPD::Project.validate_value!("http://example.com", {:MATCHES => %r{^https?://}})
          end #.to not_raise_error
        end
        it "rejects a non-matching value" do
          expect do
            AFPD::Project.validate_value!("cupcakes", {:MATCHES => %r{^https?://}})
          end.to raise_error(ValidationError)
        end
      end # describe ":MATCHES attribute"

    end # describe ".validate_value!" 

    describe ".get value" do
      before(:each) do
        @a = AFPD::Project.new("key" => "key", "name" => "name", "description" => "description")
      end
      it "returns initialized value" do
        @a[:KEY].should == "key"
      end
      it "properly canonicalizes the field name" do
        @a["Key"].should == "key"
      end
      it "returns nil for uninitialized value" do
        @a[:STATUS].should be nil
      end
    end

    describe ".set value" do
      before(:each) do
        @a = AFPD::Project.new("key" => "key", "name" => "name", "description" => "description")
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
        end.to raise_error(ValidationError)
      end
      it "coerces a scalar value to array, if needed" do
        @a[:CATEGORIES] = "testing"
        @a[:CATEGORIES].should == ["testing"]
      end
    end

    describe ".to_h" do
      before(:each) do
        @a = AFPD::Project.new("key" => "key", "name" => "name", "description" => "description")
      end
      it "returns values as a hash" do
        @a.to_h.should == {:KEY => "key", :NAME => "name", :DESCRIPTION => "description"}
      end
    end

  end # describe Project 
end # module AFPD

