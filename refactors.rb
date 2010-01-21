# BEFORE -------------------------------------------
# AFTER --------------------------------------------
# SPEC ---------------------------------------------
# --------------------------------------------------

# BEFORE -------------------------------------------
class Author < ActiveRecord::Base
  def self.escape_name(str)
    # remove apostrpohes
    temp = str.gsub('\'','')
    # remove spaces
    temp = temp.gsub(' ','')
    # remove non ascii chars (accennts etc)
    temp = ActiveSupport::Multibyte::Handlers::UTF8Handler.normalize(temp,:d).split(//u).reject { |e| e.length > 1 }.join
    return temp.downcase
  end
end
# AFTER --------------------------------------------
class Author < ActiveRecord::Base
  def self.clean_url(str)
    remove_ascii_characters(str.downcase.gsub(/\'|\s/, ''))
  end

  def self.remove_ascii_characters(str)
    ActiveSupport::Multibyte::Handlers::UTF8Handler.normalize(str,:d).split(//u).reject { |e| e.length > 1 }.join
  end
end
# SPEC ---------------------------------------------
describe Author do
  describe 'clean_urls' do   
    it "should remove spaces" do
      Author.clean_url("http://test url.com").should eql("http://testurl.com")
    end

    it "should remove apostrpohes" do
      Author.clean_url("http://test'url.com").should eql("http://testurl.com")
    end

    it "should remove ascii characters" do
      Author.clean_url("http://testàurl.com").should eql("http://testaurl.com")
    end
  end
end
# --------------------------------------------------

# BEFORE -------------------------------------------
class Author < ActiveRecord::Base
  def get_paper_count
    if self.paper_count == nil
       self.paper_count = self.papers.count
       self.save
    end
    return self.paper_count
  end
end
# AFTER --------------------------------------------
class Author < ActiveRecord::Base
  def get_paper_count
    paper_count.nil? ? initialize_paper_count : paper_count  
  end

  def initialize_paper_count
    self.paper_count = papers.count
    save and return paper_count
  end
end
# SPEC ---------------------------------------------
describe Author do
  describe 'paper_count' do
    fixtures :authors, :authorships, :papers

    it "should return a paper count" do
      authors(:jack).get_paper_count.should eql(3)
    end
      
    it "should set paper_count to the number of author papers if it's nil" do
      authors(:jack).paper_count.should be_nil
      authors(:jack).get_paper_count
      authors(:jack).paper_count.should eql(authors(:jack).papers.count)
    end
  end
end
# --------------------------------------------------

# BEFORE -------------------------------------------
class Author < ActiveRecord::Base
  def my_network_size
    if self.network_count == nil
      self.network_count = self.my_network_list.length
      self.save
    end
    return self.network_count
  end
end
# AFTER --------------------------------------------
class Author < ActiveRecord::Base
  def my_network_size
    network_count.nil? ? initialize_network_count : network_count
  end
  
  def initialize_network_count
    self.network_count = my_network_list.length
    save and return network_count
  end
end
# SPEC ---------------------------------------------
describe Author do
  describe 'network_count' do
    fixtures :authors

    before(:each) do
      @jack = authors(:jack)
      @jack.stub!(:my_network_list).and_return([mock_model(Author), mock_model(Author)])
    end

    it "should return a paper count" do
      @jack.my_network_size.should eql(2)
    end
        
    it "should set paper_count to the number of author papers if it's nil" do
      @jack.network_count.should be_nil
      @jack.my_network_size
      @jack.network_count.should eql(@jack.my_network_list.length)
    end
  end
end
# --------------------------------------------------

# BEFORE -------------------------------------------
class Author < ActiveRecord::Base
  def unique_journal_count
    full_journal_list = Array.new
    self.papers.each { |paper| full_journal_list.push(paper.journal) }
    full_journal_list.uniq.length    
  end
end
# AFTER --------------------------------------------
class Author < ActiveRecord::Base
  def unique_journal_count
    papers.collect {|paper| paper.journal}.uniq.length
  end
end
# SPEC ---------------------------------------------
describe 'paper' do
  fixtures :authors, :authorships, :papers, :journals

  it "should have a count of unique journals" do
    authors(:jack).unique_journal_count.should eql(2)
  end
end
# --------------------------------------------------

# BEFORE -------------------------------------------
class Author < ActiveRecord::Base
  def initials_with_spaces
    if self.initials.length == 1
      return self.initials
    else
      return self.initials[0..0] + ' ' + self.initials[1..1]
    end
  end
end
# AFTER --------------------------------------------
class Author < ActiveRecord::Base
  def initials_with_spaces(delimiter = ' ')
    initials.length == 1 ? initials : initials.split(//).join(delimiter)
  end
end
# SPEC ---------------------------------------------
describe 'paper' do
  it "should provide initials separated by a space" do
    author = Author.new(:lastname => 'Bauer', :initials => 'JJ')
    author.initials_with_spaces.should eql('J J')
  end
end
# --------------------------------------------------

# BEFORE -------------------------------------------
class User < ActiveRecord::Base
  def gender
    super_val = super
    (super_val == "M") ? "Male" : (super_val.blank? ? nil : "Female")
  end
end
# AFTER --------------------------------------------
class User < ActiveRecord::Base
  def gender
    super == "M" ? "Male" : "Female" unless super.blank?
  end
end
# SPEC ---------------------------------------------
describe User, 'gender' do
  it "should have return the user's gender" do
    User.new(:gender => 'M').gender.should eql('Male')
    User.new(:gender => 'F').gender.should eql('Female')
  end
  
  it "should identify if a user is male" do
    User.new(:gender => 'M').male?.should be_true
    User.new(:gender => 'F').male?.should be_false
  end
  
  it "should identify if a user is female" do
    User.new(:gender => 'F').female?.should be_true
    User.new(:gender => 'M').female?.should be_false
  end
end
# --------------------------------------------------

# BEFORE -------------------------------------------
class User < ActiveRecord::Base
  def allows_email_from_anyone?
     if self.user_id != nil && self.user.user_communication_pref.email_from_anyone == 1 && !self.preferred_email.blank?
       return true
     else
       return false
     end
  end

  def allows_email_from?(author)
    if allows_email_from_anyone? || self.user_id != nil && self.is_my_buddy?(author) && self.user.user_communication_pref.email_from_network == 1 && !self.preferred_email.blank?
      return true
    else
      return false
    end
  end

  def is_my_buddy?(author)
   if !direct_coauthors.find(:first,:conditions => ["buddy_author_id = ?",author.id]).blank? || !AuthorNetwork.find_coauthors_of(author,1).blank?
      return true
   else
      return false
   end
  end
end
# AFTER --------------------------------------------
class User < ActiveRecord::Base
  def allows_email_from_anyone?
    user.user_communication_pref.email_from_anyone == 1 && preferred_email unless user_id?
  end

  def allows_email_from?(author)
    allows_email_from_anyone? && is_my_buddy?(author) && user.user_communication_pref.email_from_network == 1
  end

  def buddies_with?(author)
    coauthors.include?(author)
  end
end
# SPEC ---------------------------------------------
# --------------------------------------------------

# BEFORE -------------------------------------------
# AFTER --------------------------------------------
# SPEC ---------------------------------------------
# --------------------------------------------------

# BEFORE -------------------------------------------
# AFTER --------------------------------------------
# SPEC ---------------------------------------------
# --------------------------------------------------

# BEFORE -------------------------------------------
# AFTER --------------------------------------------
# SPEC ---------------------------------------------
# --------------------------------------------------

# BEFORE -------------------------------------------
# AFTER --------------------------------------------
# SPEC ---------------------------------------------
# --------------------------------------------------

# BEFORE -------------------------------------------
# AFTER --------------------------------------------
# SPEC ---------------------------------------------
# --------------------------------------------------

