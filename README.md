# Product Spec Design: KindredFinds

## Overview

KindredFinds is an iOS application designed to help people recover their lost belongings. Users can easily post information about found items, including pictures, location details, and descriptive comments, to facilitate the return of these items to their rightful owners.

## 1. User Stories 

**Required Must-have Stories**

* User can post a new found item with an image.
* User can specify the location of the found item (address or map).
* User can add a comment with details about the found item.
* User can view a list of found items.
* User can view details of a found item (image, location, comments).


**Optional Nice-to-have Stories**

* User can create a user account.
* User can search for found items by keywords.
* User can filter found items by location or category.
* User can receive notifications for found items in their area.
* User can message the poster of a found item.
* User can categorize the found item.
* User can view a map of found items.

## 2. Screen Archetypes

* Found Item Post Screen: User can post a new found item with an image, location, and comments.
* Found Item List Screen: User can view a list of found items.
* Found Item Detail Screen: User can view details of a found item (image, location, comments).
* Location Selection Screen: User can select location using map or address input.

## 3. Navigation

**Tab Navigation** (Tab to Screen)

* Found Item List
* Post Found Item

**Flow Navigation** (Screen to Screen)

* Found Item List Screen
    *  Found Item Detail Screen
* Found Item Post Screen
    *  Location Selection Screen
    *  Found Item List Screen (after posting)
* Found Item Detail Screen
    *  None (but in the future, could lead to user profiles or messaging)
* Location Selection Screen
    *  Found Item Post Screen


![Recording 2025-03-22 220513 gif](https://github.com/user-attachments/assets/ec66d299-f627-449e-b4c2-a63dd4e9a0c5)

![9o9mzx](https://github.com/user-attachments/assets/1b8f6aec-2c63-4151-b096-22000d2737d7)


