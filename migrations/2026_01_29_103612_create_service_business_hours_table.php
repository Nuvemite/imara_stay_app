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
        Schema::create('service_business_hours', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_availability_id')->constrained()->onDelete('cascade');
            $table->foreignId('day_of_week_id')->constrained('days_of_week')->onDelete('cascade');
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_available')->default(true);
            $table->integer('max_bookings_this_slot')->default(1);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_business_hours');
    }
};
