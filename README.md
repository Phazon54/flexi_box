# Flexi_box, a box fully modeled in [IceSL](https://icesl.loria.fr)

This 3D-printable box is modeled to have its internal mechanism printed in flexible filament using the Phasor infiller.

![splited view of the box][box_pic]

## How is this working?

The internal mechanism is designed with the intent to use the (soon to be released) new infiller in IceSL: Phasor.
By using the scripting language to apply a spatially varying isotropy, infill angle and infill density, we generate a complex microstructure which deforms and contracts itself when we rotate its center using a key or a screw. 

![infill angle applied to the locking mechanism][angle_field]
The control field of the infill angle.

![infill isotropry applied to the locking mechanism][iso_field]
The control field of the isotropy and infill density. The gray parts will be denser and with more isotropy, the blue part will be less dense and with less isotropy.

![locking mechanism sliced with Phasor][sliced]
The sliced structure.

The collapsing of the structures in the center pulls the locking pegs inside the lid, thus opening the box.
![resting locking mechanism][resting_lock]
![opening locking mechanism][opening_lock]

## IceSL?

IceSL is a **slicer and modeler** created by the MFX team from INRIA Nancy. Among many other features, it implements a powerfull scripting interface, allowing to create models, and to fine tune every printing setting to fit any needs.
Being the product of the team's research, it is also the home of the implementation of the latest findings in optimisations and slicing techniques.

To learn more about the team and its previous work, checkout [the team's website](https://mfx.loria.fr/)

To learn more about IceSL, checkout its [website](https://icesl.loria.fr)

## Phasor? 

The Phasor infill is a novel infiller which produces freely orientable microstructures, to help design deformable 3D prints.
~~Being the implementation of a recent publication, **it will be available in the next IceSL's update**!~~ 
**It is now available in IceSL's new version !**

To learn more about the technique behind Phasor, checkout the parent publication:

[Thibault Tricard, Vincent Tavernier, Cédric Zanni, Jonàs Martínez, Pierre-Alexandre Hugron, et al..Freely orientable microstructures for designing deformable 3D prints. ACM Transactions on Graphics,Association for Computing Machinery, In press, 10.1145/3414685.3417790. hal-02524371v3](https://hal.inria.fr/hal-02524371)

## Recommended printer(s) and settings

You can print this box on any printer. However, the internal mechanism should be printed in flexible filament (TPU-85A) to work properly.

To print it properly, I would suggest these settings and hardware:
- a printer with a dual-gear extruder and with a small motor-to-nozzle distance (E3D's Hemera is perfect for this task !)
- no retraction
- a flow and speed multiplier properly tuned (in the example scripts provided with IceSL, the file [testing_tools/flow_test.lua](https://github.com/shapeforge/icesl-models/blob/master/testing_tools/flow_test.lua) can help you test quickly different values for these settings).

The other settings will be automatically set by the provided script!

## Acknowledgments

Inspired by the amazing "Expanding Mechanism Lock Box" from Maker's Muse ( [youtube video](https://www.youtube.com/watch?v=LU77kPf25Yg) | [website](https://www.makersmuse.com/expanding-lock-box) )

Prototype parts were printed in PLA on an **Original Prusa MK2S** (for the solid parts), and in NinjaTek's NinjaFlex 85A on a **CR10S Pro retroffited with a E3D Hemera** (for the flexible mechanism).


[box_pic]: assets/split_view.png
[angle_field]: assets/angle_field.png
[iso_field]: assets/iso_field.png
[sliced]: assets/sliced.png
[resting_lock]: assets/resting.jpg
[opening_lock]: assets/opening.jpg
