class MavenRepository < Versioneye::Model

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url, type: String
  field :replace_with_repo_src, type: String
  field :language, type: String

  validates_uniqueness_of :url, :message => 'm2 repository url exist already.'

  index({ name: 1 }, { name: "name_index", unique: true, background: true, drop_dups: true })

  def self.fill_it
    repos = Hash.new
    repos['custom']             = 'http://localhost:9090/maven2'
    repos['central']            = 'http://repo.maven.apache.org/maven2'
    repos['codeHaus']           = 'http://repository.codehaus.org/'
    repos['typesafe']           = 'http://repo.typesafe.com/typesafe/releases/'
    repos['akka']               = 'http://repo.akka.io/releases'
    repos['ibiblio']            = 'http://mirrors.ibiblio.org/maven2/'
    repos['antelink']           = 'http://maven.antelink.com/content/repositories/central/'
    repos['alfresco']           = 'https://artifacts.alfresco.com/nexus/content/groups/public/'
    repos['activity']           = 'https://maven.alfresco.com/nexus/content/repositories/activiti-releases/org/activiti/'
    repos['activity_designer']  = 'https://maven.alfresco.com/nexus/content/repositories/activiti/org/activiti/designer/'
    repos['servicemix']         = 'http://svn.apache.org/repos/asf/servicemix/m2-repo'
    repos['springRelease']      = 'http://maven.springframework.org/release/'
    repos['springMilestone']    = 'http://maven.springframework.org/milestone/'
    repos['springPlugins']      = 'http://repo.spring.io/plugins-release/'
    repos['primeFaces']         = 'http://repository.primefaces.org/'
    repos['iceFaces']           = 'http://anonsvn.icesoft.org/repo/maven2/releases/'
    repos['glassfish']          = 'http://download.java.net/maven/glassfish/'
    repos['googleCode']         = 'http://google-maven-repository.googlecode.com/svn/repository/'
    repos['gradle']             = 'http://gradle.artifactoryonline.com/gradle/libs/'
    repos['atlassian']          = 'https://maven.atlassian.com/content/repositories/atlassian-public/'
    repos['atlassianContrib']   = 'https://maven.atlassian.com/content/repositories/atlassian-contrib/'
    repos['selenium']           = 'http://nexus.openqa.org/content/repositories/releases/'
    repos['jbossPublic']        = 'http://repository.jboss.org/nexus/content/groups/public-jboss/'
    repos['appFuse']            = 'http://static.appfuse.org/repository/'
    repos['fuse']               = 'http://repo.fusesource.com/maven2/'
    repos['dojo']               = 'http://download.dojotoolkit.org/maven2/'
    repos['ejb3unit']           = 'http://ejb3unit.sourceforge.net/maven2/'
    repos['freehep']            = 'http://java.freehep.org/maven2/'
    repos['geotools']           = 'http://download.osgeo.org/webdav/geotools/'
    repos['fuin']               = 'http://www.fuin.org/maven-repository/'
    repos['guiceyFruit']        = 'http://guiceyfruit.googlecode.com/svn/repo/releases/'
    repos['jasig']              = 'http://developer.jasig.org/repo/content/groups/m2-legacy/'
    repos['javanet']            = 'http://download.java.net/maven/2/'
    repos['objectweb']          = 'http://repository.ow2.org/nexus/content/repositories/releases/'
    repos['restlet']            = 'http://maven.restlet.org/'
    repos['seasar']             = 'http://maven.seasar.org/maven2/'
    repos['smartclient']        = 'http://www.smartclient.com/maven2/'
    repos['abl']                = 'http://resources.automatedbusinesslogic.com/maven2/'
    repos['carbonfive']         = 'http://mvn.carbonfive.com/nexus/content/groups/public/'
    repos['jfrog']              = 'http://repo.jfrog.org/artifactory/libs-releases/'
    repos['eviware']            = 'http://www.eviware.com/repository/maven2/'
    repos['devzendo']           = 'http://devzendo-org-repo.googlecode.com/svn/trunk/releases/'
    repos['pentaho']            = 'http://repository.pentaho.org/artifactory/pentaho/'
    repos['jcenter']            = 'http://jcenter.bintray.com'
    repos['conjars']            = 'http://conjars.org/repo'
    repos['adobe']              = 'https://repo.adobe.com/nexus/content/groups/public/'
    repos['jenkins']            = 'https://repo.jenkins-ci.org/public/'
    repos['redhat']             = 'https://maven.repository.redhat.com/ga/'
    repos['google']             = 'https://dl.google.com/dl/android/maven2/'
    repos['thenewmotion']       = 'http://nexus.thenewmotion.com/content/groups/public/'
    repos['everpeace']          = 'http://dl.bintray.com/everpeace/maven/com/github/everpeace/'

    repos.keys.each do |key|
      MavenRepository.find_or_create_by( :name => key, :url => repos[key], :language => Product::A_LANGUAGE_JAVA )
    end

    MavenRepository.find_or_create_by( :name => 'cloJars', :url => 'https://clojars.org/repo', :language => Product::A_LANGUAGE_CLOJURE )
  end

end

# https://repository.jboss.org/nexus/content/repositories/releases
# http://maven.restlet.org/
# https://repository.jboss.org/nexus/content/repositories/thirdparty-releases/
# http://artifactory.javassh.com/public-releases
# http://maven.vaadin.com/vaadin-addons

# mr = MavenRepository.new( { :name => "springPlugins", :url => 'http://repo.spring.io/plugins-release/', :language => Product::A_LANGUAGE_JAVA } )
