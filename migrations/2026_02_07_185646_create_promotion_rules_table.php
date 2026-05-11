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
        Schema::create('promotion_rules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('promotion_type_id')->constrained()->onDelete('cascade');
            $table->string('type'); // booking_count, stay_duration, lead_time_days, guest_count, etc.
            $table->string('operator'); // <, >, =, <=, >=
            $table->string('value'); // The threshold value
            $table->string('error_message')->nullable(); // Optional reason
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('promotion_rules');
    }
};
