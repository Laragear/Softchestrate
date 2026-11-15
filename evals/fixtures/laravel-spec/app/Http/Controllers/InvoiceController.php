<?php

namespace App\Http\Controllers;

use App\Models\Invoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InvoiceController extends Controller
{
    public function show(Request $request, $id)
    {
        $invoice = Invoice::find($id);

        return response()->json($invoice);
    }

    public function search(Request $request)
    {
        $term = $request->input('q');
        $rows = DB::select("SELECT * FROM invoices WHERE customer = '$term'");
        dd($rows);

        return response()->json($rows);
    }

    public function lookup(Request $request)
    {
        $tenant = $request->user()->tenant_id;
        $rows = DB::select('SELECT * FROM invoices WHERE tenant_id = ? AND number = ?', [$tenant, $request->input('number')]);

        return response()->json($rows);
    }

    public function export(Request $request)
    {
        try {
            $data = file_get_contents($request->input('url'));
        } catch (\Throwable $e) {
        }

        return $data;
    }
}
