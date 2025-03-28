# The rest api

Here you have to create some controllers and modifications.

As you can see we have a very goofy session managing,
I've created the login endpoint for you as an example.

The token is communicated in header with `token` name

We decied to not give you database and focusing to the problem solving skills. The `songpushTest\datas` basicly
trying to be the datasource.

This is the first task where the hhvm/hack knowledge is profit,
but if you don't have, don't worry There is nothing magic, and the tasks doesn't require any language specific solution.

You can find many description here: https://docs.hhvm.com/hack/ <br />
The standard library: https://docs.hhvm.com/hsl/reference/function/ <br />
For the router: https://github.com/hhvm/hack-route <br />
The Response and Request interfaces: https://github.com/hhvm/hack-http-request-response-interfaces

Except these, any other third party library not necessary for solve each task here.

## To start it

Here we are using composer, if you are working from any container which contains `hhvm`, there you have to install
the **php** and **composer** too. We need **PHP** only for composer commands

The minimum **HHVM** version is `4.168.2`

To start the server you can use the attached `start-server.sh` or following the command, create a container for it,
or use the `docker-compose.yaml`

# Create get me endpoint

path: `/me`<br />
method: `GET`

## Requirements

- login

## Response

```json
{
  "success": true,
  "id": int,
  "nickName": string,
  "name": string,
  "imAgeRestricted": bool
}
```

# Create get user endpoints

path: `/user/:id:`<br />
method: `GET`

## Response

If the :id: not exists, then response with _HTTP/404_

if the the :id: is your session id, then

```json
{
  "success": true,
  "id": int,
  "nickName": string,
  "name": string,
  "imAgeRestricted": bool
}
```

else

```json
{
  "success": true,
  "id": int,
  "name": string
}
```

# Create user search endpoint

path: `/user`<br />
method: `GET`

## Optional search query params

| name  | type        | comment                                                               |
| :---- | :---------- | :-------------------------------------------------------------------- |
| name  | string      | Search in the users names                                             |
| ids   | Vector<int> | If any of this gived, find all of the users with this id              |
| skip  | int         | If not gived, the default is 0. Skip these first elements             |
| limit | int         | If not gived, the default is 3. Maximum how many item in the response |

## Response

```json
{
  "success": true,
  "results": Vector<User>,
  "hasMore": bool,
}
```

The `User` is equal with the above one response, so:

if the the :id: is your session id, then

```json
{
  "success": true,
  "id": int,
  "nickName": string,
  "name": string,
  "imAgeRestricted": bool
}
```

else

```json
{
  "success": true,
  "id": int,
  "name": string
}
```

# Create get Media endpoint

path: `/media/:id`</br >
method: `GET`

# Requirements

# Response

If the :id: not exists, then response with _HTTP/404_

If the `media->ageRestricted` and you are not logged, or you are under 18 year, then response with _HTTP/404_

If the `media->private` and `media->owner` is not you then response with _HTTP/404_

if the `media->owner->id` is you session id then:

```json
{
  "success": true,
  "id": int,
  "owner": int,
  "private": bool,
  "ageRestricted": bool,
  "title": string,
  "type": media\Type,
}
```

else

```json
{
  "success": true,
  "id": int,
  "owner": int,
  "ageRestricted": bool,
  "title": string,
  "type": media\Type,
}
```

# Create media search endpoint

path: `/media`<br />
method: `GET`

## Optional search query params

| name          | type        | comment                                                                       |
| :------------ | :---------- | :---------------------------------------------------------------------------- |
| title         | string      | Search in the media title                                                     |
| ids           | Vector<int> | If any of this gived, find all of the media with this id                      |
| owner         | int         | If any of this gived, find all of the media with this id                      |
| ageRestricted | bool        | If it gived, the result could only contain media, which ok for this condition |
| private       | bool        | If it gived, the result could only contain media, which ok for this condition |
| skip          | int         | If not gived, the default is 0. Skip this elements                            |
| limit         | int         | If not gived, the default is 10                                               |

## Response

Same the **User search** and **Get media** combination, follow the defined logics, don't forget, it is a list endpoint

# Change the get me endpoint

if the client call this endpoint wihtout session, then the response will be _HTTP/401_

With this we can tell better the client, what is our problem, not just `success: false`

# Refactor the response models

For the response will be more parsable, the success response where we have any values

be this:

```json
{
  "success": true,
  "value": GenericValue
}
```

# Enable the agerestricted contents for the session

This task description and the story are silly, but don't care about it.

So if the user behind the session is under 18,
by calling this endpoint, with her/his password, she/he can valadiate a parent is be with him, and he can reach
`ageRestricted` medias

## Endpoint

path: `/enable`<br />
method: `PUT`

## Response

```json
{
  "success: bool
}
```

# Revoke the permission for ageRestricted contents

This is the opposite version of the **Enable the agerestricted contents for the session**

## Endpoint

path: `/enable`<br />
method: `DELETE`

## Response

```json
{
  "success: bool
}
```

# Download media endpoint

As you can see there is a `src` property in the Media object

## Endpoint

path: `/media/:id:/download`<br />
method: `GET`

## Response

The media binary data

# Time to refactor the errors

Where the `response.success` === false

then that would great if we inform the client what is our problem

# Feel free to add any other endpoint and function to this api
