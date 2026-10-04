# SupportCandy REST API Bulk Export (for migration to Dolibarr)

SupportCandy does **not** publish a stable, documented SQL schema for direct DB exports. The stable contract documented by SupportCandy is its REST API.

This document captures the **exact REST API requests** (as documented by SupportCandy) to bulk export the data needed for migration.

## 0) Prerequisites

### Enable SupportCandy REST API

- In SupportCandy settings, ensure the REST API is enabled (SupportCandy calls out a REST API enable/disable control in its Advanced settings documentation).

### Authentication

- SupportCandy REST APIs require an authenticated WordPress user.
- SupportCandy documents Basic Authorization using a WordPress Application Password.


Practical note (what to parameterize):

- `SC_BASE_URL` (example: `https://helpdesk.example.com`)
- `SC_WP_USERNAME`
- `SC_WP_APP_PASSWORD`

Then build the header:

- `Authorization: Basic base64("${SC_WP_USERNAME}:${SC_WP_APP_PASSWORD}")`

## 1) Sanity check (auth works)

- `GET /wp-json/supportcandy/v2/current-user`

## 2) Catalogs (export once)

- Statuses: `GET /wp-json/supportcandy/v2/statuses`
- Priorities: `GET /wp-json/supportcandy/v2/priorities`
- Categories: `GET /wp-json/supportcandy/v2/categories`
- Ratings: `GET /wp-json/supportcandy/v2/ratings`

## 3) Agents and customers (paged)

### Agents

- `GET /wp-json/supportcandy/v2/agents?page=1&per_page=20&search=`

### Customers

- `GET /wp-json/supportcandy/v2/customers?page=1&per_page=20&search=`

## 4) Custom fields (paged + options)

### List custom fields

- `GET /wp-json/supportcandy/v2/custom-fields?page=1&per_page=20&filter=all`

Filters documented:

- `all`
- `ticket_fields`
- `agentonly_fields`
- `customer_fields`

### Get one custom field

- `GET /wp-json/supportcandy/v2/custom-fields/<id>`

### Get options for a field (if `has_options` is true)

- `GET /wp-json/supportcandy/v2/custom-fields/<id>/options`
- `GET /wp-json/supportcandy/v2/custom-fields/<id>/options/<option_id>`

## 5) Tickets (paged)

### List tickets

- `GET /wp-json/supportcandy/v2/tickets?page=1&per_page=20&filter=all&orderby=date_updated&order=DESC`

Parameters documented:

- `page` (default 1)
- `per_page` (default 20)
- `filter` (default `all`)
- `orderby` (default `date_updated`)
- `order` (default `DESC`)
- `search`
- `ticket_id`
- `email`
Support endpoints documented:

- Filters list: `GET /wp-json/supportcandy/v2/tickets/filters`
- Orderby list: `GET /wp-json/supportcandy/v2/tickets/filters/orderby`

### Get one ticket

- `GET /wp-json/supportcandy/v2/tickets/<id>`

## 6) Attachments (by id)

SupportCandy documents:

- Upload: `POST /wp-json/supportcandy/v2/attachments`
- Fetch one attachment: `GET /wp-json/supportcandy/v2/attachments/<id>`

For migration, you typically discover attachment IDs from ticket detail / thread detail payloads, then fetch each attachment by id.

## 7) Pagination loop rule (how to bulk everything)

For every paged endpoint (`tickets`, `customers`, `agents`, `custom-fields`):

- Start at `page=1`.
- Increase `page` until the returned list is empty.
- Persist each page response to disk.

## 8) If you need explicit thread endpoints

SupportCandy also has a documented **v1** API collection (Postman documentation) that includes explicit thread-related routes such as:

- `/wp-json/supportcandy/v1/tickets/{id}/threads`
- `/wp-json/supportcandy/v1/tickets/{id}/addReply`
- `/wp-json/supportcandy/v1/tickets/{id}/addNote`

This v1 API uses a login/token model and a `secret_key` per its documentation.


### v1 Authentication

- Login: `POST /wp-json/supportcandy/v1/login` (body includes `username`, `password`, `secret_key`)
- Then send `auth_user` + `auth_token` (from login response) in subsequent requests.

### v1 Export-critical endpoints (explicit history)

- List tickets: `POST /wp-json/supportcandy/v1/tickets`
- Get ticket: `GET /wp-json/supportcandy/v1/tickets/{id}`
- Ticket filters: `POST /wp-json/supportcandy/v1/tickets/filters`
- Ticket threads: `POST /wp-json/supportcandy/v1/tickets/{id}/threads`
- Add reply: `POST /wp-json/supportcandy/v1/tickets/{id}/addReply`
- Add note: `POST /wp-json/supportcandy/v1/tickets/{id}/addNote`
- Thread history: `GET /wp-json/supportcandy/v1/threads/{historyId}`

### v1 Attachment endpoints (upload-side, but useful to understand payloads)

- Attach file as guest: `POST /wp-json/supportcandy/v1/attachGuestFile`
- Attach file as registered user: `POST /wp-json/supportcandy/v1/attachRegisteredUserFile`

## 9) Recommended export output format

For the migration inventory file target:

- `research/supportcandy_api_inventory_2026-08-25.json`

Use:

- `meta` (export timestamp, site, auth method)
- `catalogs` (statuses/priorities/categories)
- `agents`
- `customers`
- `fields` (custom fields + options)
- `tickets` (paged)
- `attachments` (resolved by id)

