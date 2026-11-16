# Plan: Soft deletes for Post

- id: post-soft-deletes
- revision: 1
- status: completed

## Goal and acceptance criteria
Add soft deletes to Post with a restore endpoint. AC1: deleting a post sets deleted_at; AC2: restore clears it.
