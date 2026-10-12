<?php

declare(strict_types=1);

namespace Letsfix\Tickets\Dependency;

final class TicketModuleGuard
{
    public static function assertEnabled(bool $enabled): void
    {
        if (!$enabled) {
            throw new MissingTicketModuleException(
                'Enable the native Dolibarr Ticket module before installing Letsfix Tickets.'
            );
        }
    }
}