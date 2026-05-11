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
            $table->foreignId('payment_gateway_id')->nullable()->after('user_id')->constrained('payment_gateways')->onDelete('set null');
            $table->string('payment_intent_id')->nullable()->after('payment_gateway_id');
            $table->string('payment_status')->nullable()->default('pending')->after('payment_intent_id'); // pending, processing, succeeded, failed, refunded
            $table->json('payment_metadata')->nullable()->after('payment_status');
            $table->timestamp('paid_at')->nullable()->after('payment_metadata');

            $table->index('payment_intent_id');
            $table->index('payment_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropForeign(['payment_gateway_id']);
            $table->dropIndex(['payment_intent_id']);
            $table->dropIndex(['payment_status']);
            $table->dropColumn(['payment_gateway_id', 'payment_intent_id', 'payment_status', 'payment_metadata', 'paid_at']);
        });
    }
};
