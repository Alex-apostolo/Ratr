import 'dart:ffi';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Classes, getters, builders, etc. for accessing json go here for the time being //

//TODO modify basic house class and factory as per criteria established in deliverable 2 

//This is a basic house class for display purposes, generally to be substantiated by json

List<House> houseList = [];
List<Landlord> landlordList = [];

class Landlord{
  String name;
  int avgRating;
  String lat;
  List<dynamic> houses;
  List<dynamic> reviews;

  Landlord({this.name,this.avgRating,this.houses,this.reviews,this.lat});

  factory Landlord.fromJson(Map<String,dynamic> json){
    return Landlord(
      name: json["name"],
      reviews: json["reviews"],
      houses: json["houses"],
      avgRating: json["avgRating"],
      lat: json["houses"]["lat"],
    );
  }
}

class House{
  int id;
  double avgRating;
  int bedrooms;
  int houseNum;
  double lat;
  double long;
  String postCode;
  String street;
  int price;

  House({this.lat,this.long,this.avgRating,this.bedrooms,this.houseNum,this.street,this.postCode,this.price});

  factory House.fromJson(Map<String,dynamic> json){
    return House(
      lat: json["lat"],
      long: json["long"],
      avgRating: json["avgRating"].toDouble(),
      houseNum: json["houseNumber"],
      street: json["houseStreet"],
      bedrooms: json["roomInfo"]["numBedrooms"],
      postCode: json["postCode"],
      price: json["pricePerAnnum"],
    );
  }
}

class Review{
  double rating;
  String review;

  Review({this.rating, this.review});

  factory Review.fromJson(Map<String,dynamic> json){
    return Review(
      rating: json["rating"].toDouble(),
      review: json["review"]
    );
    
  }
}

//Helper function that, when given a landlords reviews json return a list of reviews in review data structure (ideally)
Review FixReviews(Map<String,dynamic> json){
  Review thisRev = Review.fromJson(json);
  return thisRev;
  
}


// Retreives a list of houses from database
Future fetchHouses() async {
  //clears previous version of houseList
  houseList = [];
  final response = await http.get('https://us-central1-ridr-cc2ec.cloudfunctions.net/getHouses');

  if(response.statusCode == 200){
    //REturn house from json
    //final out = HouseBasic.fromJson(json.decode(response.body));
    var data = json.decode(response.body);
    for(Map i in data){
      houseList.add(House.fromJson(i));
    }
  } else {
    throw Exception('Failed to load houses! (Probably the server is down)');
  }
}

Future fetchLandlords() async {
  //Clears previously stored version of landlord list
  landlordList = [];
  final response = await http.get('https://us-central1-ridr-cc2ec.cloudfunctions.net/getLandlords');
  if(response.statusCode == 200){
    var data = json.decode(response.body);
    print(data);
    for(Map i in data){
      landlordList.add(Landlord.fromJson(i));
    }
    // Fixing json encoding stuff within landlord datastructure internal lists, this is NOT good practice but it works 
    for(Landlord landlord in landlordList){
      for(var j = 0; j < landlord.reviews.length; j++){
        landlord.reviews[j] = Review.fromJson(landlord.reviews[j]);
      }
    }
    print(landlordList[0].houses);
  }
  else{
    throw Exception('Failed to load landlords! (Probably the server is down');
  }
}