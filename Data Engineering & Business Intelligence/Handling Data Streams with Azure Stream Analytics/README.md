**INSTRUCTIONS**

You are going to use Azure Stream Analytics to process a data stream of ATM transactions and answer
stream queries. The schema of the stream is: (ATMCode, CardNumber, Type, Amount)
1. Create a students account at: https://azure.microsoft.com/en-us/free/students/
2. Setup an Event Hub.
3. Generate a Security Access Signature (use a terminal with windows operationg system): https://github.com/sandrinodimattia/RedDog/releases
4. Edit Generator.html (open with a text editor, e.g.: Sublime or Notepad++) and update the CONFIG variables. Keep the “js” folder in the same folder as the Generator.html file.
5. Feed the Event Hub with the use of Generator.html (In order to start the Stream Generator, open the Generator.html with a web browser, e.g.: Chrome and press the “Send Data” button.)
6. Setup a Storage account.
7. Upload the Reference Data files to your storage account.
8. Setup a Stream Analytics Job.
9. Use the Event Hub + Reference Data Files as Input.
10. Create a Blob Storage Output.

**SCENARIO**

You have access to a data stream that’s generated from ATMs. Each event contains data related to the transaction that took place. You are asked to create an Azure Analytics solution for the tasks listed in the “QUERIES” section.

**REFERENCE DATA**

AREA.json
- Geographical Information.
- Connects each area_code with a city and a country.
- The “area_code” of this dataset can be joined with the “area_code” of ATM.json
ATM.json
- Information about the ATM.
- Connects each ATM with an area.
- The “atm_code” of this dataset can be joined with the input’s “ATMCode” section.
Customer.json
- Information about each customer.
- Provides demographic information about each customer.
- The “card_number” of this dataset can be joined with the input’s “CardNumber” section.

**DATA STREAM INPUT**

Events generated have the following format:
{
"ATMCode": 13,
"CardNumber": 5610827137784218,
"Type": 0,
"Amount": 37
}

**FIELDS DESCRIPTION**

- ATMCode: Information about the type of the ATM. Can be joined with Atm.json
- CardNumber: The card number related to the transaction. Can be joined with Customer.json
- Type: The type of the transaction. There are two types of transactions, type “1” and type “0”.
- Amount: The amount of the transaction.

**SETUP**

**1.  Create a student account**

![image.png](attachment:image.png)


**2.  Set up an Event Hub**

![image.png](attachment:image.png)

![image-2.png](attachment:image-2.png)

**3. Generate a Security Access Signature**

![image.png](attachment:image.png)

![image-2.png](attachment:image-2.png)

**4. Edit the Generator.html (e.g., opened with Sublime) and update the Config variables.**

![image.png](attachment:image.png)

**5. Feed the Event Hub with the use of Generator.html**

![image-2.png](attachment:image-2.png)

**6. Set up a storage account.**

![image.png](attachment:image.png)

![image-2.png](attachment:image-2.png)

![image-3.png](attachment:image-3.png)

**7. Upload the Reference Data files to our storage**

![image.png](attachment:image.png)

**8. Set up a Stream Analytics Job**

![image.png](attachment:image.png)

![image-2.png](attachment:image-2.png)

**9. Use the Event Hub & Reference Data Files as Input**

![image.png](attachment:image.png)

![image-2.png](attachment:image-2.png)

The sampling Data of our Input

![image-3.png](attachment:image-3.png)

Inputs after uploading all the reference data files

![image-4.png](attachment:image-4.png)

**10. Create a Blob Storage Output**

![image.png](attachment:image.png)

**QUERIES**

**1. Show the total “Amount” of “Type = 0” transactions at “ATM Code = 21” of the last 10 minutes.
Repeat as new events keep flowing in (use a sliding window).**

![image-2.png](attachment:image-2.png)

**2. Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour.
Repeat once every hour (use a tumbling window).** 

![image.png](attachment:image.png)

**3. Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour.
Repeat once every 30 minutes (use a hopping window).**

![image.png](attachment:image.png)

**4. Show the total “Amount” of “Type = 1” transactions per “ATM Code” of the last one hour (use
a sliding window).**

![image.png](attachment:image.png)

**5. Show the total “Amount” of “Type = 1” transactions per “Area Code” of the last hour. Repeat
once every hour (use a tumbling window).**

**Area Code of ATM**

![image.png](attachment:image.png)

**Area Code of Customer**

![image.png](attachment:image.png)

**6. Show the total “Amount” per ATM’s “City” and Customer’s “Gender” of the last hour. Repeat
once every hour (use a tumbling window).**

![image.png](attachment:image.png)

**7. Alert (Do a simple SELECT “1”) if a Customer has performed two transactions of “Type = 1” in a
window of an hour (use a sliding window).**

![image.png](attachment:image.png)

**8. Alert (Do a simple SELECT “1”) if the “Area Code” of the ATM of the transaction is not the same
as the “Area Code” of the “Card Number” (Customer’s Area Code) - (use a sliding window)**

![image.png](attachment:image.png)
