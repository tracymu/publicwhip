require 'spec_helper'
# Compare results of rendering pages via rails and via the old php app

describe HomeController do
  include HTMLCompareHelper
  fixtures :all

  it "#index" do
    compare("/")
  end

  it "#faq" do
    compare("/faq.php")
  end

  it "#search" do
    compare("/search.php")

    compare("/search.php?query=2042&button=Search")
    compare("/search.php?query=Tony+Abbott&button=Search")
    compare("/search.php?query=supplementary+explanatory+memorandum&button=Search")
    compare("/search.php?query=This+is+some+test+text&button=Search")
    compare("/search.php?query=Wa-pa-pa-pa-pa-pow&button=Search")

    compare("/search.php?query=2042&button=Submit")
    compare("/search.php?query=Tony+Abbott&button=Submit")
    compare("/search.php?query=supplementary+explanatory+memorandum&button=Submit")
    compare("/search.php?query=This+is+some+test+text&button=Submit")
    compare("/search.php?query=Wa-pa-pa-pa-pa-pow&button=Submit")
  end
end
