# Mouth Morse (MM) System

## Project Focus

The focus of the project is the development of a **Mouth Morse (MM) System** whose functioning is based on the interaction with the user’s mouth.

## Literature Review

A review of existing literature identified previous uses of the thermistor for similar purposes. For example, **Bandyopadhyay et al.** employ a thermistor, supported by a breathing mask and a tube, as a sensing element for blow detection in an anemometer configuration [1].

This setup inspired the Mouth Morse System's principle: **human expiration causes a temperature increase**, which is sensed by the thermistor and **translated into Dot-Dash characters of Morse code**, if properly temporized.

## Target Users

Before developing the physical components and conditioning circuit, it is necessary to define the **target users**:

- Individuals with **severe motion pathologies** and lack of coordination.
- Those unable to **press buttons** or communicate verbally.
- Users must be able to **modulate blow duration** and interact with a **screen for communication**.

Every action is designed to be **piloted by blowing**, implemented via software using an **enhanced version of Morse code** and related commands (explained in Paragraph 4.4).

## Conditioning Circuit Design

Two main approaches for the conditioning circuit were considered:

1. **Absolute temperature detection** using two thermistors (one for the blow, one for the environment).
2. **Relative temperature change detection** at the beginning of expiration.

The second option was implemented due to its simplicity and **elimination of the need for linearization**. In this approach:

- **Time becomes the key factor** for translating blow phases into Morse code.
- The **temperature derivative** is used:
  - **Positive sign** → expiration detected.
  - **Null or negative sign** → no expiration detected.

## Physical Components Considerations

Key issues regarding the physical interface with the subject:

- **Nasal airflow** should not affect sensing.
- Thermistor should be placed **close to the mouth** during communication.
- The sensor must ensure **heat dissipation** during inspiration to avoid:
  - **Saturation**
  - **Self-heating**
- **Humidity** can affect the measurement and should be considered in design.

## Device Design and Portability

The device is intended to be **portable and wearable** for frequent use in various contexts. It features:

- Movement that is **integral with the head**, thanks to:
  - **Lateral ties**
  - **Chin prop** 
- A design focused on providing a **pleasant user experience**.

![Figure 1 – Device Wearability](images/DSC07651.JPG)
