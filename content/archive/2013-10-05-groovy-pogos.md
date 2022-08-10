---
id: 24
title: Groovy POGOs
date: 2013-10-05T21:43:42+00:00
author: ellinj
layout: post

original_post_id:
  - "15"
tags:
  - groovy
---

We are all used to the plain old java object (POJO), but what do we know about the plain old groovy object (POGO). We all know that Groovy brings convenience to the Java langauage, but what does it it bring us when dealing with standard objects?

Consider the following POJO

```java 
public class Customer {

int id;
String firstName;
String lastName;
String address;
String city;
String state;
String postalCode;

public Customer(int id, String firstName, String lastName, String address, String city, String state, String postalCode) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.address = address;
    this.city = city;
    this.state = state;
    this.postalCode = postalCode;
}

public int getId() {
    return id;
}

public void setId(int id) {
    this.id = id;
}

public String getFirstName() {
    return firstName;
}

public void setFirstName(String firstName) {
    this.firstName = firstName;
}

public String getLastName() {
    return lastName;
}

public void setLastName(String lastName) {
    this.lastName = lastName;
}

public String getAddress() {
    return address;
}

public void setAddress(String address) {
    this.address = address;
}

public String getCity() {
    return city;
}

public void setCity(String city) {
    this.city = city;
}

public String getState() {
    return state;
}

public void setState(String state) {
    this.state = state;
}

public String getPostalCode() {
    return postalCode;
}

public void setPostalCode(String postalCode) {
    this.postalCode = postalCode;
}

@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    Customer customer = (Customer) o;

    if (id != customer.id) return false;
    if (address != null ? !address.equals(customer.address) : customer.address != null) return false;
    if (city != null ? !city.equals(customer.city) : customer.city != null) return false;
    if (firstName != null ? !firstName.equals(customer.firstName) : customer.firstName != null) return false;
    if (lastName != null ? !lastName.equals(customer.lastName) : customer.lastName != null) return false;
    if (postalCode != null ? !postalCode.equals(customer.postalCode) : customer.postalCode != null) return false;
    if (state != null ? !state.equals(customer.state) : customer.state != null) return false;

    return true;
}

@Override
public int hashCode() {
    int result = id;
    result = 31 * result + (firstName != null ? firstName.hashCode() : 0);
    result = 31 * result + (lastName != null ? lastName.hashCode() : 0);
    result = 31 * result + (address != null ? address.hashCode() : 0);
    result = 31 * result + (city != null ? city.hashCode() : 0);
    result = 31 * result + (state != null ? state.hashCode() : 0);
    result = 31 * result + (postalCode != null ? postalCode.hashCode() : 0);
    return result;
}

@Override
public String toString() {
    return "Customer{" +
            "id=" + id +
            ", firstName='" + firstName + ''' +
            ", lastName='" + lastName + ''' +
            ", address='" + address + ''' +
            ", city='" + city + ''' +
            ", state='" + state + ''' +
            ", postalCode='" + postalCode + ''' +
            '}';
}
}
```

Wow, thats a lot of boilerplate code for a simple object that contains a few pieces of data about a customer. 

  * fields which contains data about our Customer
  * a constructor for creating a new Customer object
  * getters and setters for accessing the fields
  * equals and hashcode methods
  * toString methods for each field

Every time a new field is added we must update the constructors, getters, setters, equals, hashcode, and toString methods

How would that look in groovy?

```
package com.ellin.demo.com.ellin.demo.pogo

import groovy.transform.EqualsAndHashCode
import groovy.transform.ToString

@EqualsAndHashCode(includes=['id','firstName','lastName','address','city','state','postalCode'])
@ToString(includeNames=true)
class Customer {

    int id;
    String firstName;
    String lastName;
    String address;
    String city;
    String state;
    String postalCode;

}
```

When compiled this POGO automatically is given getters and setters for its private fields and a map based constructor. The following code will compile just fine. The map based constructor is used to instantiate the object and the automatically included getter is used the retrieve the value of firstName.

```
def customer = new Customer([id:1,firstName:'jeff',lastName:'ellin',address:'4 Yawkey Way',city:'Boston',state:'MA'])
println customer.toString()
assert customer.getFirstName() == 'jeff';
```

The output of the above code snippet is as follows

```
com.ellin.demo.com.ellin.demo.pogo.Customer(id:1, firstName:jeff, lastName:ellin, address:4 Yawkey Way, city:Boston, state:MA, postalCode:null)
```

### AST Class Annotations

I am also using two class annotations provided by Groovy, @EqualsAndHashCode and @ToString

<a href="http://groovy.codehaus.org/gapi/groovy/transform/EqualsAndHashCode.html" title="@EqualsAndHashCode" target="_blank">@EqualsAndHashCode</a> automatically adds the required logic for implementing .equals() and .hashCode() functions. 

[@ToString](http://groovy.codehaus.org/gapi/groovy/transform/ToString.html "@ToString") automatically generates a toString implementation based on the fields within the class.