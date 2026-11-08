<?php
Route::middleware(['throttle:api'])->group(function () {
    Route::get('/posts', [PostController::class, 'index']);
});
