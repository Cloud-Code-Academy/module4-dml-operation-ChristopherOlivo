/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Christopher Olivo
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account();
        // Set some fields on the Account
        acc.Name = 'RandomName_' + Math.random();
        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account acc = new Account();
        acc.Name = name;
        acc.Industry = industry;
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact con = new Contact();
        // Set some fields on the Contact
        con.FirstName = 'New';
        con.LastName = 'Contact';
        // Set the AccountId field to the given accountId
        con.AccountId = accountId;
        // Insert the Contact into the database
        insert con;
        // Return the Id of the newly created Contact
        return con.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact con = [SELECT Id, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
        // Update the Contact's last name
        con.LastName = newLastName;
        // Update the Contact in the database
        update con;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];

        // Update the Opportunity's stage
        opp.StageName = newStage;
        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account acc = [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId];

        // Update the Account with the given Id with the new name and industry
        acc.Name = newName;
        acc.Industry = newIndustry;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for (Opportunity opp : opportunities) {
            // Set the Opportunity's Stage to Qualification
            opp.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opp.CloseDate = Date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opp.Amount = 50000;
        }
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        Account acc;
    List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];

    if (accounts.isEmpty()) {
        // Account does not exist, so we create a new one
        acc = new Account(Name = accountName);
        upsert acc;  // Using upsert to handle if it exists by some other means
    } else {
        // Account already exists
        acc = accounts[0];
    }

    // Loop through the opportunity names and create Opportunities
    List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();
    for (String oppName : oppNames) {
        // Create a new opportunity and associate it with the found/created account
        Opportunity opp = new Opportunity(
            Name = oppName,
            AccountId = acc.Id, // Link to the Account
            CloseDate = Date.today(),
            StageName = 'Prospecting' 
        );
        opportunitiesToUpsert.add(opp);
    }

    // Upsert the Opportunities
    upsert opportunitiesToUpsert Opportunity.Name; // Upsert based on Opportunity name
}
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

		Account acc;

		// if the Account exists, update the description
        if (!accounts.isEmpty()) {
            acc = accounts[0]; // Get the existing account
            acc.Description = 'Updated Account';
        } else {
            // otherwise, create a new Account and set the description
            acc = new Account(Name = accountName, Description = 'New Account');
        }
		// Upsert the Account
        upsert acc;

		return acc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        for (Contact contact : contactsToUpsert) {
            // Extract the Account Name from Contact's LastName
            String accountName = contact.LastName;
            // Get the account based on the name or create one if it doesn't exist
            Account acc = upsertAccount(accountName);
            // Link the Contact to its Account using the Account Id
            contact.AccountId = acc.Id;
        }
		// Upsert the Contacts
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Create a list to store the Lead records
        List<Lead> leadsToInsert = new List<Lead>();

        // Loop through each Lead name and create Lead records
        for (String leadName : leadNames) {
            Lead newLead = new Lead(
            LastName = leadName, 
            Company = 'Test Company' // Company is a required field for Lead
        );
        leadsToInsert.add(newLead);
    }

        // Insert the Leads
        insert leadsToInsert;

        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> cases = new List<Case>();
        // Insert the cases
        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case(
                accountId = AccountId,
                Subject = 'Case ' + i,
                Status = 'New'
            );
            // Add cases to the list
            cases.add(newCase);
        }
        // Insert the cases
        insert cases;

        // Delete the cases
        delete cases;
    }
}