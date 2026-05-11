<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->foreignId('booking_type_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('weekday_base_price', 10, 2)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['booking_type_id']);
            $table->dropColumn(['booking_type_id', 'weekday_base_price']);
        });
    }
};
