
CREATE TABLE public.driver (
                mobile VARCHAR NOT NULL,
                name VARCHAR NOT NULL,
                family VARCHAR NOT NULL,
                status BOOLEAN NOT NULL,
                numberOfTrips BIGINT NOT NULL,
                CONSTRAINT mobile PRIMARY KEY (mobile)
);


CREATE TABLE public.cars (
                pelak VARCHAR NOT NULL,
                color VARCHAR NOT NULL,
                model VARCHAR NOT NULL,
                produce_year VARCHAR NOT NULL,
                driver_mobile VARCHAR NOT NULL,
                CONSTRAINT pelak PRIMARY KEY (pelak)
);


CREATE TABLE public.passenger (
                mobile VARCHAR NOT NULL,
                name VARCHAR NOT NULL,
                lastName VARCHAR NOT NULL,
                acc_balance BIGINT NOT NULL,
                numberOfTrips BIGINT NOT NULL,
                CONSTRAINT mobile PRIMARY KEY (mobile)
);


CREATE TABLE public.trip_header (
                trip_num VARCHAR NOT NULL,
                passenger_mobile VARCHAR NOT NULL,
                driver_mobile VARCHAR NOT NULL,
                price VARCHAR NOT NULL,
                CONSTRAINT trip_header_pk PRIMARY KEY (trip_num)
);


CREATE TABLE public.payment (
                trip_num VARCHAR NOT NULL,
                discount VARCHAR NOT NULL,
                amount VARCHAR NOT NULL,
                method VARCHAR NOT NULL,
                CONSTRAINT payment_pk PRIMARY KEY (trip_num)
);


CREATE TABLE public.comment (
                trip_num VARCHAR NOT NULL,
                pass_comment VARCHAR NOT NULL,
                pass_rate VARCHAR NOT NULL,
                driver_comment VARCHAR NOT NULL,
                driver_rate VARCHAR NOT NULL,
                CONSTRAINT comment_pk PRIMARY KEY (trip_num)
);


CREATE TABLE public.trip_detail (
                trip_num VARCHAR NOT NULL,
                source VARCHAR NOT NULL,
                destination VARCHAR NOT NULL,
                stop_time VARCHAR NOT NULL,
                CONSTRAINT trip_detail_pk PRIMARY KEY (trip_num)
);


CREATE TABLE public.specific_address (
                passenger_mobile VARCHAR NOT NULL,
                location  VARCHAR NOT NULL,
                CONSTRAINT specific_address_pk PRIMARY KEY (passenger_mobile, location )
);


ALTER TABLE public.cars ADD CONSTRAINT driver_cars_fk
FOREIGN KEY (driver_mobile)
REFERENCES public.driver (mobile)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.trip_header ADD CONSTRAINT driver_trip_header_fk
FOREIGN KEY (driver_mobile)
REFERENCES public.driver (mobile)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.specific_address ADD CONSTRAINT passenger_specific_address_fk
FOREIGN KEY (passenger_mobile)
REFERENCES public.passenger (mobile)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.trip_header ADD CONSTRAINT passenger_trip_header_fk
FOREIGN KEY (passenger_mobile)
REFERENCES public.passenger (mobile)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.trip_detail ADD CONSTRAINT trip_header_trip_detail_fk
FOREIGN KEY (trip_num)
REFERENCES public.trip_header (trip_num)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.comment ADD CONSTRAINT trip_header_comment_fk
FOREIGN KEY (trip_num)
REFERENCES public.trip_header (trip_num)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.payment ADD CONSTRAINT trip_header_payment_fk
FOREIGN KEY (trip_num)
REFERENCES public.trip_header (trip_num)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;
