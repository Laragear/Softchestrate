<?php
use App\Http\Controllers\InvoiceController;

Route::middleware('auth')->group(function () {
    Route::get('/invoices/{id}', [InvoiceController::class, 'show']);
    Route::get('/invoices-search', [InvoiceController::class, 'search']);
    Route::get('/invoices-lookup', [InvoiceController::class, 'lookup']);
    Route::get('/invoices-export', [InvoiceController::class, 'export']);
});
