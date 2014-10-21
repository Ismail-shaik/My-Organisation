public class documentExt 
{
    public documentExt(ApexPages.StandardController controller) 
    {
        Document d = (Document) controller.getRecord();
        d.folderid = UserInfo.getUserId();
    }
}