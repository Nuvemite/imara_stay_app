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
        Schema::table('cancellation_policies', function (Blueprint $table) {
            if (!Schema::hasColumn('cancellation_policies', 'listing_type_id')) {
                $table->foreignId('listing_type_id')->nullable()->constrained('listing_types')->nullOnDelete();
            }
            if (!Schema::hasColumn('cancellation_policies', 'rules')) {
                $table->json('rules')->nullable();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('cancellation_policies', function (Blueprint $table) {
            $table->dropForeign(['listing_type_id']);
            $table->dropColumn(['listing_type_id', 'rules']);
        });
    }
};
