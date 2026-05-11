<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->json('cancellation_policy_snapshot')->nullable()->after('status');
            $table->decimal('refund_amount', 10, 2)->nullable()->after('cancellation_policy_snapshot');
            $table->text('cancellation_reason')->nullable()->after('refund_amount');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['cancellation_policy_snapshot', 'refund_amount', 'cancellation_reason']);
        });
    }
};
