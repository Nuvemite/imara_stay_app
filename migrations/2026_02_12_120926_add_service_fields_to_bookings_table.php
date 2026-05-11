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
            $table->foreignId('time_slot_id')->nullable()->after('end_date')->constrained('listing_time_slots')->onDelete('set null');
            $table->foreignId('service_offering_id')->nullable()->after('time_slot_id')->constrained('service_offerings')->onDelete('set null');
            $table->string('start_time')->nullable()->after('service_offering_id');
            $table->string('end_time')->nullable()->after('start_time');

            $table->index('time_slot_id');
            $table->index('service_offering_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropForeign(['time_slot_id']);
            $table->dropForeign(['service_offering_id']);
            $table->dropIndex(['time_slot_id']);
            $table->dropIndex(['service_offering_id']);
            $table->dropColumn(['time_slot_id', 'service_offering_id', 'start_time', 'end_time']);
        });
    }
};
