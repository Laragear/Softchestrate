<?php

namespace App;

class UserRepository
{
    /**
     * Retrieve a user by its identifier.
     */
    public function find(int $id): ?User
    {
        return $this->store[$id] ?? null;
    }

    /**
     * Persist the user in the store.
     */
    public function save(User $user): void
    {
        $this->store[$user->id] = $user;
    }

    private array $store = [];
}
