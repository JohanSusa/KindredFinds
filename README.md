# Product Spec Design: KindredFinds
[TOC]

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

## User flows
```sequence
Title: KindredFinds
participant user1
User2->B: Lost Iteam
B->C: Take a picture of the found item
C->D: Add detailed comments
D-->>E: Posting a Found Item
E-->>user1: Browsing Found Items
```