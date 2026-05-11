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
        Schema::table('service_offerings', function (Blueprint $table) {
            $table->string('photo_url')->nullable()->after('description');
            $table->integer('max_guests')->nullable()->default(1)->after('duration_minutes');
            $table->integer('min_age')->nullable()->default(0)->after('max_guests');
            $table->decimal('min_booking_amount', 10, 2)->nullable()->after('base_price');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('service_offerings', function (Blueprint $table) {
            $table->dropColumn(['photo_url', 'max_guests', 'min_age', 'min_booking_amount']);
        });
    }
};
