#!/usr/bin/env bundle exec rspec
require "spec_helper"

describe TieredCategoryExpressions do
  it "has a version number" do
    expect(TieredCategoryExpressions::VERSION).not_to be nil
  end

  describe "TieredCategoryExpressions::Expression()" do
    context "given a TieredCategoryExpressions::Expression" do
      it "returns its argument" do
        arg = TieredCategoryExpressions::Expression.parse("foo > bar")
        expect(TieredCategoryExpressions::Expression(arg)).to be arg
      end
    end

    context "given a string" do
      it "returns a TieredCategoryExpressions::Expression" do
        expect(TieredCategoryExpressions::Expression("foo > bar")).to eq \
          TieredCategoryExpressions::Expression.parse("foo > bar")
      end
    end
  end

  describe TieredCategoryExpressions::Expression do
    describe ".parse" do
      context "given a valid string" do
        it "returns the proper TieredCategoryExpressions::Expression" do
          parsed = TieredCategoryExpressions::Expression.parse("foo >> !bar > !qux|quux >> baz")
          expect(parsed).to be_a(TieredCategoryExpressions::Expression)
          expect(parsed.to_s).to eq "foo >> ! bar > ! quux | qux >> baz"
        end
      end

      [
        ".",
        ".foo",
        "foo..",
        "foo!",
        "!!foo",
        "foo?",
        "foo >",
        "foo >>",
        "foo > .",
        "foo > !",
        "foo >> !",
        "foo >>> bar",
        "foo || bar",
        "foo < bar",
        "(foo)"
      ].each do |str|
        context "given #{str.inspect}" do
          it "raises a ParseError" do
            expect { TieredCategoryExpressions::Expression.parse(str) }.to raise_error \
              TieredCategoryExpressions::ParseError
          end
        end
      end
    end

    tce_examples = [
      # [TCE, category, should_match?]
      ["foo", %w[foo],     true],
      ["foo", %w[FOO],     true],
      ["foo", %w[foo bar], true],
      ["foo", %w[bar],     false],
      ["foo", %w[fooo],    false],
      ["foo", [],          false],

      ["foo > bar", %w[foo bar],     true],
      ["foo > bar", %w[foo BAR],     true],
      ["foo > bar", %w[foo bar baz], true],
      ["foo > bar", %w[foo],         false],
      ["foo > bar", %w[foo baz],     false],
      ["foo > bar", %w[foo barr],    false],
      ["foo > bar", %w[fooo bar],    false],

      ["foo > bar > baz", %w[foo bar baz],     true],
      ["foo > bar > baz", %w[foo bar baz qux], true],
      ["foo > bar > baz", %w[foo bar],         false],
      ["foo > bar > baz", %w[foo bar qux],     false],
      ["foo > bar > baz", %w[foo qux baz],     false],

      ["b%",   %w[bar],   true],
      ["b%",   %w[baz],   true],
      ["%o",   %w[foo],   true],
      ["%o",   %w[boo],   true],
      ["f%o",  %w[foo],   true],
      ["f%o",  %w[foooo], true],
      ["%",    %w[foo],   true],
      ["foo%", %w[foo],   true],
      ["%",    %w[],      false],
      ["f%",   %w[bar],   false],
      ["f%",   %w[bff],   false],

      ["f%",   %w[foo bar],     true],
      ["%oo",  %w[foo bar],     true],
      ["f%r",  %w[foo bar],     false],
      ["%ar",  %w[foo bar],     false],
      ["ba%",  %w[foo bar],     false],
      ["f%z",  %w[foo bar baz], false],

      ["foo > %", %w[foo bar],     true],
      ["foo > %", %w[foo bar baz], true],
      ["foo > %", %w[foo],         false],

      ["f% > % > %z", %w[foo bar baz], true],
      ["f% > % > %z", %w[foo baz bar], false],
      ["f% > % > %z", %w[bar foo baz], false],

      ["foo | bar", %w[foo], true],
      ["foo | bar", %w[bar], true],
      ["foo | bar", %w[baz], false],
      ["foo | bar", [],      false],

      ["foo | bar | qux", %w[foo], true],
      ["foo | bar | qux", %w[bar], true],
      ["foo | bar | qux", %w[qux], true],
      ["foo | bar | qux", %w[baz], false],
      ["foo | bar | qux", [],      false],

      ["!foo", %w[foo],     false],
      ["!foo", %w[foo bar], false],
      ["!foo", %w[fooo],    true],
      ["!foo", %w[fo],      true],
      ["!foo", %w[bar baz], true],

      ["!%", %w[foo],     false],
      ["!%", %w[foo bar], false],

      ["foo > !bar", %w[foo bar],     false],
      ["foo > !bar", %w[foo baz],     true],
      ["foo > !bar", %w[foo baz bar], true],

      ["!foo > !bar", %w[foo bar],     false],
      ["!foo > !bar", %w[foo baz],     false],
      ["!foo > !bar", %w[baz bar],     false],
      ["!foo > !bar", %w[baz foo bar], true],
      ["!foo > !%",   %w[bar baz],     false],

      [">> baz", %w[baz],         true],
      [">> baz", %w[foo baz],     true],
      [">> baz", %w[foo bar baz], true],
      [">> baz", %w[foo bar],     false],
      [">> baz", %w[bazz],        false],

      ["foo >> baz", %w[foo baz],         true],
      ["foo >> baz", %w[foo bar baz],     true],
      ["foo >> baz", %w[foo bar qux baz], true],
      ["foo >> baz", %w[foo],             false],
      ["foo >> baz", %w[baz],             false],
      ["foo >> baz", %w[foo bar],         false],
      ["foo >> baz", %w[bar baz],         false],

      ["foo", %w[foo],         true],
      ["foo", %w[foo bar],     true],
      ["foo", %w[foo bar baz], true],
      ["foo", %w[bar foo],     false],

      [">> !baz", %w[baz],         false],
      [">> !baz", %w[foo baz],     false],
      [">> !baz", %w[foo bar baz], false],

      [">> foo > !baz", %w[baz foo bar],         true],
      [">> foo > !baz", %w[baz foo baz],         false],
      [">> foo > !baz", %w[baz bar foo baz],     false],
      [">> foo > !baz", %w[baz bar qux foo baz], false],

      [">> !foo > bar", %w[baz bar],     true],
      [">> !foo > bar", %w[baz qux bar], true],
      [">> !foo > bar", %w[bar],         false],
      [">> !foo > bar", %w[foo],         false],
      [">> !foo > bar", %w[foo bar],     false],
      [">> !foo > bar", %w[baz foo bar], false],
      [">> !foo > bar", %w[baz qux],     false],

      ["foo > b% > !baz > qux | quux >> ! foo | bar", %w[foo bar xxx quux yyy zzz], true],
      ["foo > b% > !baz > qux | quux >> ! foo | bar", %w[foo bar xxx quux yyy foo], false],
      ["foo > b% > !baz > qux | quux >> ! foo | bar", %w[foo bar xxx quux bar yyy], false],

      ["foo", ["FOO"], true],
      ["123", ["123"], true],

      ["foo bar", ["foobar"],   true],
      ["foobar",  ["foo bar"],  true],
      ["foo bar", ["foo bar"],  true],

      ["foobar", ["foo_bar"],  true],
      ["foobar", ["foo-bar"],  true],
      ["foobar", ["foo+bar"],  true],
      ["foobar", ["foo&bar"],  true],
      ["foobar", ["foo,bar"],  true],
      ["foobar", ["foo;bar"],  true],
      ["foobar", ["foo:bar"],  true],
      ["foobar", ["foo/bar"],  true],
      ["foobar", ["foo\\bar"], true],
      ["foobar", ["foo|bar"],  true],
      ["foobar", ["foo=bar"],  true],

      ["foo", %w['foo'],       true],
      ["foo", %w["foo"],       true],
      ["foo", %w[<{[(foo)]}>], true],
      ["foo", %w[*foo*],       true],
      ["foo", %w[%foo%],       true],
      ["foo", %w[`foo`],       true],
      ["foo", %w[foo?],        true],
      ["foo", %w[foo!],        true],

      ["Ħöø ÇåŖ ĢŬŬĐ", ["ĤŐŌ ČĄr Ğûüď"], true],

      ["foo.", %w[foo],           true],
      ["foo.", %w[foo bar],       false],

      ["foo | bar.", %w[foo],     true],
      ["foo | bar.", %w[bar],     true],
      ["foo | bar.", %w[foo bar], false],
      ["foo | bar.", %w[bar foo], false],

      ["foo > bar.", %w[foo bar],     true],
      ["foo > bar.", %w[foo bar baz], false],

      ["foo. > bar", %w[foo],           true],
      ["foo. > bar", %w[foo bar],       true],
      ["foo. > bar", %w[foo bar baz],   true],
      ["foo. > bar", %w[foo baz],       false],

      ["foo. > bar.", %w[foo],         true],
      ["foo. > bar.", %w[foo bar],     true],
      ["foo. > bar.", %w[foo baz],     false],
      ["foo. > bar.", %w[foo bar baz], false],

      ["foo. > bar. > baz", %w[foo],             true],
      ["foo. > bar. > baz", %w[foo bar],         true],
      ["foo. > bar. > baz", %w[foo bar baz],     true],
      ["foo. > bar. > baz", %w[foo bar baz qux], true],
      ["foo. > bar. > baz", %w[foo baz],         false],

      # Examples from LANGREF.md:

      ["agf > groente > komkommer", ["AGF", "Groente", "Komkommer"], true],
      ["agf > groente > komkommer", ["AGF", "Groente", "Komkommer", "Snack komkommer"], true],
      ["agf > groente > komkommer", ["AGF", "Groente"], false],
      ["agf > groente > komkommer", ["AGF", "Groente", "Tomaat"], false],
      ["agf > groente > komkommer", ["Groente & fruit", "Groente", "Komkommer"], false],

      ["agf >> komkommer", ["AGF", "Komkommer"], true],
      ["agf >> komkommer", ["AGF", "Komkommer", "Snack komkommer"], true],
      ["agf >> komkommer", ["AGF", "Groente", "Komkommer", "Snack komkommer"], true],
      ["agf >> komkommer", ["AGF"], false],
      ["agf >> komkommer", ["AGF", "Snack komkommer"], false],
      ["agf >> komkommer", ["AGF", "Groente", "Snack komkommer"], false],

      ["groente% > %komkommer", ["Groente", "Komkommer"], true],
      ["groente% > %komkommer", ["Groente & fruit", "Snack komkommer"], true],

      ["!komkommer", ["Komkommer"], false],

      ["veldsla | ijsbergsla | rucola", ["Veldsla"], true],
      ["veldsla | ijsbergsla | rucola", ["IJsbergsla"], true],
      ["veldsla | ijsbergsla | rucola", ["Rucola"], true],

      ["agf > groente > komkommer.", ["AGF", "Groente", "Komkommer"], true],
      ["agf > groente > komkommer.", ["AGF", "Groente", "Komkommer", "Snack komkommer"], false],

      ["agf > groente. > komkommer", ["AGF", "Groente"], true],
      ["agf > groente. > komkommer", ["AGF", "Groente", "Komkommer"], true],
      ["agf > groente. > komkommer", ["AGF", "Groente", "Komkommer", "Snack komkommer"], true],
      ["agf > groente. > komkommer", ["AGF", "Groente", "Tomaat"], false],

      ["agf > groente. > komkommer.", ["AGF", "Groente"], true],
      ["agf > groente. > komkommer.", ["AGF", "Groente", "Komkommer"], true],
      ["agf > groente. > komkommer.", ["AGF", "Groente", "Tomaat"], false],
      ["agf > groente. > komkommer.", ["AGF", "Groente", "Komkommer", "Snack komkommer"], false],

      ["groente > seizoensgroente > %", ["Groente", "Seizoensgroente", "Pastinaak"], true],
      ["groente > seizoensgroente > %", ["Groente", "Seizoensgroente", "Vers", "Pastinaak"], true],
      ["groente > seizoensgroente > %", ["Groente", "Seizoensgroente"], false],

      [">> !komkommer%", ["Komkommer"], false],
      [">> !komkommer%", ["Komkommer & fruit"], false],
      [">> !komkommer%", ["AGF", "Komkommer"], false],
      [">> !komkommer%", ["AGF", "Komkommer & fruit"], false],
      [">> !komkommer%", ["AGF", "Groente", "Komkommer"], false],

      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood", "Baby", "Flessen"], true],
      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood", "Huisdier", "Aanlijnriemen"], true],
      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood", "Baby", "Babyvoeding"], false],
      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood", "Huisdier", "Diervoeding"], false],
      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood", "Babyvoeding"], false],
      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood", "Diervoeding"], false],
      ["nonfood >> ! babyvoeding | diervoeding", ["Nonfood"], false],

      ["voeding. >> %voeding.", ["Voeding"], true],
      ["voeding. >> %voeding.", ["Voeding", "Babyvoeding"], true],
      ["voeding. >> %voeding.", ["Voeding", "Diervoeding"], true],
      ["voeding. >> %voeding.", ["Voeding", "Baby", "Babyvoeding"], true],
      ["voeding. >> %voeding.", ["Voeding", "Dier", "Diervoeding"], true],
      ["voeding. >> %voeding.", ["Voeding", "AGF"], false],
      ["voeding. >> %voeding.", ["Voeding", "Babyvoeding", "Newborn"], false],
      ["voeding. >> %voeding.", ["Voeding", "Diervoeding", "Hond"], false],
      ["voeding. >> %voeding.", ["Voeding", "Baby", "Babyvoeding", "Newborn"], false],
      ["voeding. >> %voeding.", ["Voeding", "Dier", "Diervoeding", "Hond"], false]
    ]

    describe "#matches?" do
      tce_examples.each do |tce, category, expected|
        it "is #{expected.inspect} when #{TCE(tce).inspect} is matched with #{category.inspect}" do
          expect(TCE(tce).matches?(category)).to be expected
        end
      end
    end

    describe "#as_sql_like_query" do
      [
        ["foo" ,              "foo>%"],
        ["!foo",              "%>%"],
        ["!%oo",              "%>%"],
        ["FOO BÄR",           "foobar>%"],
        ["foo > bar",         "foo>bar>%"],
        ["foo > b%r",         "foo>b%r>%"],
        ["foo > bar > baz",   "foo>bar>baz>%"],
        ["foo > bar | baz",   "foo>%>%"],
        ["foo > !bar",        "foo>%>%"],
        ["foo > !bar | baz",  "foo>%>%"],
        ["foo >> bar",        "foo>%bar>%"],
        ["foo >> !bar",       "foo>%>%"],
        ["foo >> bar | baz",  "foo>%>%"],
        ["foo >> !bar | baz", "foo>%>%"],
        [">> foo > bar",      "%foo>bar>%"],
        [">> foo | bar",      "%>%"],
        [">> !foo",           "%>%"],
        [">> !fo%",           "%>%"],
        [">> !foo | bar",     "%>%"],
        ["foo.",              "foo>"],
        ["foo > bar.",        "foo>bar>"],
        ["foo. > bar",        "foo>%"],
        ["foo > bar. > baz",  "foo>bar>%"]
      ].each do |tce, expected|
        it "returns #{expected.inspect} for #{TCE(tce).inspect}" do
          expect(TCE(tce).as_sql_like_query).to eq expected
        end
      end

      # Assert absence of false negatives (false positives are ok):
      tce_examples.select { |_, _, e| e }.each do |tce, category|
        preprocessed = TieredCategoryExpressions::Preprocessor.call(category)
        it "matches #{preprocessed.inspect} for #{TCE(tce).inspect}" do
          expect(sql_like?(TCE(tce).as_sql_like_query, preprocessed)).to be true
        end
      end
    end

    describe "#>" do
      it "concatenates strings and expressions" do
        expect(TCE("noot.") > ">> foobar|quux" > TCE("!mies")).to eq TCE("noot. >> foobar|quux > !mies")
      end
    end

    describe "#==" do
      it "is true if they match the same input" do
        expect(TCE("!aap >> foobar|quux") ==  TCE("!  aap>>quux  | foo bar")).to be true
      end

      it "implicitly converts its argument to a TCE" do
        expect(TCE("!aap >> foobar|quux") ==  "!  aap>>quux  | foo bar").to be true
      end

      it "is false if they do not match the same input" do
        expect(TCE("!aap >> foobar|quux") ==  TCE("!aap >> quux")).to be false
      end
    end

    describe "#to_s" do
      it "is its expression" do
        tce = TCE("foo>>!bar.>!bbb|aaa>%.")
        expect(TCE(tce.to_s)).to eq tce
      end

      it "excludes implicit leading child operator" do
        expect(TCE(">foo")).to eq "foo"
        expect(TCE(">!foo")).to eq "! foo"
        expect(TCE(">>foo")).to eq ">> foo"
        expect(TCE(">>!foo")).to eq ">> ! foo"
      end
    end

    describe "#strict?" do
      it "is false if subcategories must be matched (default)" do
        expect(TCE("foo > bar").strict?).to be false
        expect(TCE("foo. > bar").strict?).to be false
      end

      it "is true if subcategories must not be matched (trailing \".\")" do
        expect(TCE("foo.").strict?).to be true
        expect(TCE("foo > bar.").strict?).to be true
      end
    end
  end

  describe "TieredCategoryExpressions::Generator.call" do
    [
      [["Foo"],               "Foo"],
      [["Foo", "Bar"],        "Foo > Bar"],
      [["Føø", "Bär"],        "Føø > Bär"],
      [["Foo bar", "baz"],    "Foo bar > baz"],
      [[" Foo  bar "],        "Foo bar"],
      [["Foo", "Bar", "Baz"], "Foo > Bar > Baz"],
      [["Foo-bar"],           "Foobar"],
      [["F^^", "$ar"],        "F > ar"]
    ].each do |category, expected|
      it "returns #{TCE(expected).inspect} for #{category.inspect}" do
        tce = TieredCategoryExpressions::Generator.call(category)
        expect(tce).to be_a TieredCategoryExpressions::Expression
        expect(tce.to_s).to eq expected
        expect(tce.matches?(category)).to be true
      end
    end

    context "with strict set to true" do
      it "creates a strict expression object" do
        tce = TieredCategoryExpressions::Generator.call(%w[foo bar], strict: true)
        expect(tce).to be_strict
      end
    end

    [
      [],
      [""],
      [" "],
      [" §@$ "],
      ["Foo", "Bar", "-"]
    ].each do |category|
      it "returns nil for #{category.inspect}" do
        expect(TieredCategoryExpressions::Generator.call(category)).to be nil
      end
    end
  end
end
