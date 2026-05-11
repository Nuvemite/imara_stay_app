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
        Schema::create('payment_gateways', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g., "Stripe", "M-Pesa", "PayPal"
            $table->string('slug')->unique(); // e.g., "stripe", "mpesa", "paypal"
            $table->string('provider'); // Provider identifier for code logic
            $table->text('description')->nullable();
            $table->string('icon')->nullable(); // Icon URL or class name
            $table->json('configuration')->nullable(); // Dynamic configuration (API keys, endpoints, etc.)
            $table->json('supported_currencies')->nullable(); // Array of supported currency codes
            $table->json('supported_countries')->nullable(); // Array of supported country codes
            $table->boolean('is_active')->default(true);
            $table->boolean('is_test_mode')->default(false);
            $table->integer('sort_order')->default(0);
            $table->json('metadata')->nullable(); // Additional metadata
            $table->timestamps();

            $table->index(['is_active', 'sort_order']);
            $table->index('slug');
            $table->index('provider');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payment_gateways');
    }
};
