class Developer < Versioneye::Model

# In this collection the crawlers are writing directly the author & maintainer
# information. Each product & version pair can have multiple entries here.
# The AuthorService is generating uniq. Author profiles out of this raw data.

  include Mongoid::Document
  include Mongoid::Timestamps

  # This developer belongs to the product with this attributes
  field :language        , type: String
  field :prod_key        , type: String
  field :version         , type: String

  # combination of language and prod_key
  field :lang_key        , type: String

  field :developer       , type: String # This is the username of the developer! Legacy. The name is taken from maven. The very first implementation.
  field :name            , type: String # This is the real name of the developer!
  field :email           , type: String
  field :homepage        , type: String
  field :twitter         , type: String
  field :github          , type: String
  field :organization    , type: String
  field :organization_url, type: String
  field :role            , type: String
  field :timezone        , type: String
  field :contributor     , type: Boolean, default: false

  # This will set to true from a background job, after an Author profile was created for this developer.
  field :to_author       , type: Boolean, default: false


  index({ language: 1, prod_key: 1, version: 1, name: 1 }, { name: "language_prod_key_version_name_index", background: true, unique: true, drop_dups: true })
  index({ language: 1, prod_key: 1, version: 1 },          { name: "language_prod_key_version_index",      background: true })
  index({ language: 1, prod_key: 1 },                      { name: "language_prod_key_index",              background: true })
  index({ name: 1 }, { name: "name_index", background: true })


  before_save :update_lang_key


  def to_s
    "#{name} - #{email}"
  end


  def dev_identifier
    return self.name      if !self.name.to_s.empty?
    return self.developer if !self.developer.to_s.empty?
    return self.email     if !self.email.to_s.empty?
    return self.organization if !self.organization.to_s.empty?
    return self.ids
  end


  def to_param
    Author.encode_name(self.dev_identifier)
  end


  def author
    name_id = Author.encode_name( self.dev_identifier )
    Author.where( :name_id => name_id ).first
  end


  def product
    product = Product.fetch_product language, prod_key
    if product.nil? && self.language.to_s.eql?(Product::A_LANGUAGE_JAVA)
      product = Product.fetch_product Product::A_LANGUAGE_CLOJURE, prod_key
    end
    if product.nil? && Product.where(:prod_key => prod_key).count.to_i == 1
      product = Product.where(:prod_key => prod_key).first
    end
    update_language product
    product
  end


  def update_language product
    if product && !self.language.to_s.eql?(product.language.to_s)
      return nil if Developer.where(:language => product.language, :prod_key => self.prod_key).count.to_i > 0

      self.language = product.language
      self.save
    end
  rescue => e
    log.error e.message
    log.error e.backtrace.join("\n")
  end


  def update_lang_key
    self.lang_key = "#{language}:::#{prod_key}".downcase
  end


  def self.find_by language, prod_key, version, name = nil
    if name.nil?
      return Developer.where( language: language, prod_key: prod_key, version: version )
    else
      return Developer.where( language: language, prod_key: prod_key, version: version, name: name )
    end
  end


end
