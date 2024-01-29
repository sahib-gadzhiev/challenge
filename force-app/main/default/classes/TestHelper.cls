@isTest
public with sharing class TestHelper {

    public final static INTEGER MISSION_NUMBER_FOR_INSERT = 10;
    public final static INTEGER CONTACT_NUMBER_FOR_INSERT = 3;
    public static void generateData() {
        Guild__c guild = new Guild__c();
        guild.Name = 'Test Guild';
        guild.vision__c = 'Test Vision';
        insert guild;

        List<Superhero_Mission__c> missionList = new List<Superhero_Mission__c>();
        for(Integer i = 0; i < MISSION_NUMBER_FOR_INSERT; i ++) {
            Superhero_Mission__c mission = new Superhero_Mission__c();
            mission.Complexity_Rank__c = 'B';
            mission.Deadline__c = Date.today() + 10;
            mission.Details__c = 'Test Details';
            mission.Guild__c =guild.Id;
            mission.Is_Public__c = false;
            mission.Reward__c = 100;
            mission.Subject__c = 'Test Mission ' + i;
            missionList.add(mission);
        }
        
        Insert missionList;

        //User Information part
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        Account account_1 = new Account( Name = 'Community'  );
        insert account_1;
        
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < CONTACT_NUMBER_FOR_INSERT; i ++) {
            Contact cnt = new Contact(AccountId = account_1.Id, LastName = 'xgeek' + i, Email = 'sahib.testcommunity' + i + '@gmail.com');
            contactList.add(cnt);
        }
        insert contactList;
        
        
        User user_1 = new User( 
            Email = contactList[0].Email,
            ProfileId = profile_1.Id, 
            UserName = 'yourusername@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contactList[0].Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
        );
        insert user_1;
        
        List<Hero__c> heroList = new List<Hero__c>();
        for(Integer i = 0; i < CONTACT_NUMBER_FOR_INSERT; i ++) {
            Hero__c hero = new Hero__c();
            hero.Contact__c = contactList[i].Id;
            hero.Guild__c = guild.Id;
            hero.Name = 'Test Name' + i;
            hero.Rank__c = 'B';
            heroList.add(hero);
        }
        insert heroList;
        // Now perform your tests using the created user
        // System.runAs(testUser) {
        //     // Your code that involves community user functionality
        //     // For example, if your code retrieves the current user's ID:
        //     System.assertEquals(testUser.Id, UserInfo.getUserId(), 'User ID should match');
        // }
    }
}