# Paczucha
An application that will allow you to track parcels in many courier companies in one place.<br>
Fully coded in Swift.
<br>
<br>

# 1. Home View <br>

The application on the home screen shows all added parcels, the logo of the serving courier company and the last downloaded tracking status. After clicking on a given shipment, the user goes to the detailed view. Previously downloaded statuses are available even offline. <br> <br>
The user can refresh the status of all packages with the button on the right side of the bar. Can also go to the archive view with the button on the left side of the bar. A floating button with a plus sign takes you to the adding new parcel view.
<br><br>
Table cells also have two buttons that show up when the user swipes the cells to the left. The button with the orange background moves the selected shipment to the archive, and the button with the red background permanently removes the shipment from the database.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/136289985-387e8e8b-82a1-45e8-8c06-4f32ff248c09.png" width="300"> <img src="https://user-images.githubusercontent.com/45921300/136290630-80fc2870-d4c8-4a49-b201-dd3912a082a5.png" width="300"></p>
<br>

# 2. Add new parcel view <br>

The user adds a new package to the database by providing the following information: package number, own name, carrier.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/135772321-034b00fe-f879-484b-b62b-3303ca23a592.png" width="300"> <img src="https://user-images.githubusercontent.com/45921300/135772323-7a13c361-93b4-42af-bd7d-4c797c09817a.png" width="300"></p>
<br>

# 3. Detailed view of the parcel. 

All package statuses are displayed along with the time and date of their occurrence. Information includes title and description.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/135772335-4c682cd0-7f03-4919-bae1-3f291c9ce884.png" width="300"> <img src="https://user-images.githubusercontent.com/45921300/135772339-b95fbd1b-f28b-4fc5-8c51-421afb1cf01a.png" width="300"></p>
<br>

# 4. Archive view. 

A view very similar to the home view. However, the statuses of all parcels in archive will no longer be refreshed. <br>
Table cells also have two buttons that show up when the user swipes the cells to the left. The button with the green background moves the selected shipment to the active parcels, and the button with the red background permanently removes the shipment from the database.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/136292015-d336aa13-be2b-460f-9273-9795d4797e3d.png" width="300"> <img src="https://user-images.githubusercontent.com/45921300/136292017-3f3859ac-57cb-4d14-aeda-18f41837b292.png" width="300"></p>
<br>

<br>
<br>
<b>The app is still under development, more options and courier companies will be added soon!</b>
<br>
<br>
Full tech stack used in project:

| Name | Description          |
| ------------- | ----------- |
| Combine      | Handling of asynchronous events by combining event-processing operators.|
| CoreData     | Framework used to store information about added parcels and their statuses.  |
| SOAP     | Communication protocol used to retrieve information about some parcels. This protocol is used, for example, by Poczta Polska.   |
| REST API    | Interface used to retrieve information about some parcels. This protocol is used, for example, by Inpost.   |
| TextFieldEffect  | Framework used to create better text fields.  |

