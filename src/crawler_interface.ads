-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Ada.Finalization;
package Crawler_Interface is
   type Screen is new Ada.Finalization.Limited_Controlled with null record;
private
   overriding procedure Initialize (This: in out Screen);
   overriding procedure Finalize (This: in out Screen);
end Crawler_Interface;
