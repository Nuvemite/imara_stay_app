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
        Schema::table('listings', function (Blueprint $table) {
            $table->foreignId('cancellation_policy_id')->nullable()->constrained('cancellation_policies')->nullOnDelete();
            $table->time('check_in_start')->default('15:00:00');
            $table->time('check_in_end')->nullable()->default('22:00:00');
            $table->time('check_out_time')->default('11:00:00');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['cancellation_policy_id']);
            $table->dropColumn(['cancellation_policy_id', 'check_in_start', 'check_in_end', 'check_out_time']);
        });
    }
};
