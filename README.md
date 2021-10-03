# Paczucha
An application that will allow you to track parcels in many courier companies in one place.<br>
Fully coded in Swift.
<br>
<br>


1. The application on the home screen shows all added shipments, the logo of the serving courier company and the last downloaded tracking status. The user can refresh the status of all packages with the button on bar. Previously downloaded statuses are available even offline.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/135772286-e175e089-9cc3-4ed6-8d5a-3496918c17f8.png" width="300"> </p>
<br>

2. Adding a new package view. The user adds a new package by providing the following information: package number, own name, carrier.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/135772321-034b00fe-f879-484b-b62b-3303ca23a592.png" width="300"> <img src="https://user-images.githubusercontent.com/45921300/135772323-7a13c361-93b4-42af-bd7d-4c797c09817a.png" width="300"></p>
<br>

3. Detailed view of the parcel. All package statuses are displayed along with the time and date of their occurrence. Information includes title and description.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/135772335-4c682cd0-7f03-4919-bae1-3f291c9ce884.png" width="300"> <img src="https://user-images.githubusercontent.com/45921300/135772339-b95fbd1b-f28b-4fc5-8c51-421afb1cf01a.png" width="300"></p>
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

