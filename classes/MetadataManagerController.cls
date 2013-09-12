public class MetadataManagerController{
    // Instance constants
    public final String API_USERNAME = 'apiuser@lamobiledevweek2013.dev';
    public final String API_PASSWORD = 'lamobiledevweek2013';
    public final String API_SECURITY_TOKEN = '';
    public final Double API_LATEST_VERSION = 27.0;
    
    // Instance variables
    public PartnerWSDL.Soap partnerSvc{get; set;}
    public PartnerWSDL.LoginResult loginResult{get; set;}
    public PartnerWSDL.GetUserInfoResult userInfoResult{get; set;}
    public String loggedInUserName{get; set;}
    public Boolean loginSuccess{get; set;}
    public Boolean loginFailure{get; set;}
    public MetadataWSDL.Metadata metaSvc{get; set;}
    public DescribeMetadataObject[] descMetaObjects{get; set;}
    public String[] metadataTypes{get; set;}
    
    public MetadataManagerController(){
        this.partnerSvc = new PartnerWSDL.Soap();
        this.loginSuccess = false;
        this.loginFailure = false;
    }
    
    public void login(){
        this.loginResult = this.partnerSvc.login(this.API_USERNAME, this.API_PASSWORD + this.API_SECURITY_TOKEN);
        if(this.loginResult != null && this.loginResult.sessionId != null){
            this.partnerSvc.SessionHeader = new PartnerWSDL.SessionHeader_element();
            this.partnerSvc.SessionHeader.sessionId = this.loginResult.sessionId;
            this.partnerSvc.endpoint_x = 'https://na15-api.salesforce.com/services/Soap/u/27.0';
            this.userInfoResult = partnerSvc.getUserInfo();
            if(this.userInfoResult != null && this.userInfoResult.userFullName != null){
                this.loginSuccess = true;
                this.loggedInUserName = this.userInfoResult.userFullName;
                this.metaSvc = new MetadataWSDL.Metadata();
                this.metaSvc.SessionHeader = new MetadataWSDL.SessionHeader_element();
                this.metaSvc.SessionHeader.sessionId = this.loginResult.sessionId;
                MetadataWSDL.DescribeMetadataResult descResult = this.metaSvc.describeMetadata(this.API_LATEST_VERSION);
                if(descResult != null && descResult.metadataObjects != null){
                    MetadataWSDL.DescribeMetadataObject[] wsdlDescMetaObjects = descResult.metadataObjects;
                    this.descMetaObjects = new DescribeMetadataObject[]{};
                    for(MetadataWSDL.DescribeMetadataObject metaObj : wsdlDescMetaObjects){
                        DescribeMetadataObject descMetaObj = new DescribeMetadataObject();
                        descMetaObj.childXmlNames = metaObj.childXmlNames != null ? metaObj.childXmlNames : new String[]{};
                        descMetaObj.directoryName = metaObj.directoryName;
                        descMetaObj.inFolder = metaObj.inFolder;
                        descMetaObj.metaFile = metaObj.metaFile;
                        descMetaObj.suffix = metaObj.suffix;
                        descMetaObj.xmlName = metaObj.xmlName;
                        this.descMetaObjects.add(descMetaObj);
                        this.metadataTypes.add(metaObj.xmlName);
                    }
                    this.metadataTypes = new String[]{};
                    this.metadataTypes.sort();
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error invoking Metadata API.'));
                }
            }else{
                this.loginFailure = true;
            }
        }else{
            this.loginFailure = true;
        }
    }
    
    public class DescribeMetadataObject{
        public String[] childXmlNames;
        public String directoryName;
        public Boolean inFolder;
        public Boolean metaFile;
        public String suffix;
        public String xmlName;
    }
    //comment
}