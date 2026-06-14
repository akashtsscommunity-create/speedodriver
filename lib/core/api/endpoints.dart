class Endpoints {
  static const login = '/api/auth/login';
  static const signup = '/api/auth/signup';
  static const sendotp = '/api/users/sendotp';
  static const forgotPassword = '/api/users/forgotPassword';
  static const verifyotp = '/api/users/verifyotp';
  static const saveemailaccount = '/api/users/saveemailaccount';
  static String toggleActiveAccount(int messageId) => '/api/users/ToggleActiveAccount/$messageId';
  static const refresh = '/api/auth/refresh';
  static const updateProfile = '/api/auth/update-profile';
  static const prefs = '/api/prefs';
  static const uiThemeCurrent = '/api/ui-themes/current';
  static const saveTemplates = '/api/campaigns/template/master';
  static String getImages(String id) => '/proxy/img?h=$id';
  static const getAssestLibrary = '/api/assets/search';
  static String tmplates({required String tenantId, String? status,String? search, int page=1, int pageSize=20}) {
    return '/api/demo/templates?tenantId=$tenantId&status=$status&search=$search&page=$page&pageSize=$pageSize';
  }
  static const saveContacts = '/api/marketing/contacts/upsert';
  static const getContactDetails = '/api/marketing/contacts/search';
  static const getListDetails = '/api/marketing/contacts/list';
  static const saveContactListEndPoints = '/api/marketing/contacts/list/upsert';
  static const ApplyActionEndPoints = '/api/marketing/contacts/list/member/upsert/bulk';
  static const saveCampaign = '/api/campaigns';
  static const updateCampaign = '/api/campaigns/upsert';
  static const updateLinkCampaign = '/api/campaigns/template/link/update';
  static String getcampaigns({required String tId,String? q,String? status, int limit=50, int offset=0}) {
    return '/api/campaigns?q=$q&tenantId=$tId&status=$status&limit=$limit&offset=$offset';
  }
  static String getcampaignDetails({required String campaignId}) {
    return '/api/campaigns/$campaignId';
  }
  static const getMasterTemplates = '/api/campaigns/template/master';
  static String getMasterTemplate(String id) => '/api/campaigns/template/master/$id';
  static String getTemplate(String id) => '/api/campaigns/template/link/$id';
  static String saveCampiagnLinkTemplate(String campaignId,String templateID) => '/api/campaigns/template/link/$campaignId/$templateID';
  static String saveCampiagnSchedule(String campaignId) => '/api/campaigns/${campaignId}/schedule';
  static const attachments_init = '/api/Attachments/initiate';
  static const attachments_chunking = '/api/Attachments/chunks';
  static const attachments_finalize = '/api/Attachments/finalize';
}